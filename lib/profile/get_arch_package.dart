// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 0:44

import 'package:get_arch_core/domain/env_config.dart';
import 'package:get_arch_core/get_arch_part.dart';
import 'package:get_arch_core/interface/i_dialog.dart';
import 'package:get_arch_core/interface/i_network.dart';
import 'package:get_arch_core/interface/i_storage.dart';
import 'package:get_arch_core/profile/get_arch_application.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_arch_quick_start/infrastructure/storage_impl.dart';
import 'package:get_arch_quick_start/infrastructure/ui/dialog_impl.dart';
import 'package:hive/hive.dart';

final _g = GetIt.instance;

///
/// [packageEnvConfig] 为null时将会使用globalEnvConfig的值
/// [httpConfig] http配置, 如果打算手动注册IHttp的INetConfig,则无需填写
/// [socketConfig] socket配置, 如果打算手动ISocket的INetConfig,则无需填写
/// [openStorageImpl] storage配置, 默认关闭
/// [assignStoragePath] Hive的初始化路径,不建议手动配置,如果要手动配置,请确保[openStorageImpl]为true
/// [onLocalTestStoragePath] Hive本地测试时使用的路径,不建议手动配置
/// [openDialogImpl] Dialog实现, 默认关闭
class QuickStartPackage extends IGetArchPackage {
  final HttpConfig httpConfig;
  final SocketConfig socketConfig;
  final bool openStorageImpl;
  final String assignStoragePath;
  final String onLocalTestStoragePath;
  final bool openDialogImpl;

  QuickStartPackage({
    EnvConfig pkgEnvConfig,
    this.httpConfig,
    this.socketConfig,
    this.openStorageImpl: false,
    this.assignStoragePath,
    this.onLocalTestStoragePath: './_hive_test_cache',
    this.openDialogImpl: false,
  })  : assert(openStorageImpl != null),
        super(pkgEnvConfig);

  @override
  Map<String, bool> get printBoolStateWithRegTypeName => {
        'IHttp': httpConfig != null,
        'ISocket': socketConfig != null,
        'IStorage': openStorageImpl != null,
        'IDialog': openDialogImpl,
      };

  @override
  Map<String, String> printOtherStateWithEnvConfig(EnvConfig config) => {
        if (httpConfig != null) 'IHttp': '配置为: $httpConfig',
        if (socketConfig != null) 'ISocket': '配置为: $socketConfig',
        if (openStorageImpl != null)
          'IStorage':
              '配置路径: ${assignStoragePath ?? '默认[getApplicationDocumentsDirectory()]'}'
                  '\n  本地测试时使用的路径: $onLocalTestStoragePath',
      };

  Future<void> initPackage(EnvConfig config) async {
    if (openStorageImpl)
      await initHive(
          assignStoragePath: assignStoragePath,
          onLocalTestStoragePath: onLocalTestStoragePath);
  }

  Future<void> initPackageDI(EnvConfig config) async {
    if (httpConfig != null) {
      _g.registerFactory<HttpConfig>(() => httpConfig);
      _g.registerLazySingleton<IHttp>(() => HttpImpl(_g<HttpConfig>()));
    }

    if (socketConfig != null) {
      _g.registerFactory<SocketConfig>(() => socketConfig);
      _g.registerLazySingleton<ISocket>(() => SocketImpl(_g<SocketConfig>()));
    }
    // 这里将Box注册为<String>, 存储对象的json字符串, 一般情况下性能与TypeAdapter区别不大
    // 使用TypeAdapter,每个类型都需要不同的id, 在使用多个package的情况下极易出错
    if (openStorageImpl) {
      final box =
          await Hive.openBox<String>('default_box_get_arch_quick_start');
      _g.registerFactory<Box<String>>(() => box);
      _g.registerLazySingleton<IStorage>(() => StorageImpl(_g<Box<String>>()));
    }
    if (openDialogImpl) await initDialog(_g, config.envSign.toString());
  }
}

initDialog(GetIt g, String environment) {
  if (environment == 'prod') {
    g.registerLazySingleton<IDialog>(() => QuickDialog());
  }

//Register test Dependencies --------
  if (environment == 'test') {
    g.registerLazySingleton<IDialog>(() => TestDialog());
  }

//Register dev Dependencies --------
  if (environment == 'dev') {
    g.registerLazySingleton<IDialog>(() => DevDialog());
  }
}
