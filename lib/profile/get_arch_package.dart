// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 0:44

import 'package:get_arch_core/domain/env_config.dart';
import 'package:get_arch_core/get_arch_part.dart';
import 'package:get_arch_core/interface/i_network.dart';
import 'package:get_arch_core/interface/i_storage.dart';
import 'package:get_arch_core/profile/get_arch_application.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_arch_quick_start/infrastructure/storage_impl.dart';
import 'package:hive/hive.dart';

import 'get_arch_package.iconfig.dart';

final _g = GetIt.instance;

///
/// [httpConfig] http配置, 如果打算手动注册IHttp的INetConfig,则无需填写
/// [socketConfig] socket配置, 如果打算手动ISocket的INetConfig,则无需填写
/// [openStorageImpl] storage配置,如果想要手动实现,则设为false
/// [assignStoragePath] Hive的初始化路径,不建议手动配置,如果要手动配置,请确保[openStorageImpl]为true
/// [onLocalTestStoragePath] Hive本地测试时使用的路径,不建议手动配置
class QuickStartPackage extends IGetArchPackage {
  final HttpConfig httpConfig;
  final SocketConfig socketConfig;
  final bool openStorageImpl;
  final String assignStoragePath;
  final String onLocalTestStoragePath;
  final bool openDialogHelperImpl;

  QuickStartPackage({
    this.httpConfig,
    this.socketConfig,
    this.openStorageImpl: true,
    this.assignStoragePath,
    this.onLocalTestStoragePath: './_hive_test_cache',
    this.openDialogHelperImpl: true,
  }) : assert(openStorageImpl != null);

  @override
  String printPackageConfigInfo(EnvConfig config) => '''
  HTTP实现: 已${httpConfig == null ? '关闭' : '启用(IHttp), 配置为: $httpConfig'}
  Socket实现: 已${socketConfig == null ? '关闭' : '启用(ISocket), 配置为: $socketConfig'}
  Storage实现: 已${openStorageImpl == null ? '关闭' : '启用(IStorage)\n  配置路径: ${assignStoragePath ?? '默认[getApplicationDocumentsDirectory()]'}\n  本地测试时使用的路径: $onLocalTestStoragePath'}
  DialogHelper实现: 已${!openDialogHelperImpl ? '关闭' : '启用(IDialogHelper)'}
   ''';

  Future<void> initPackage(EnvConfig config) async {
    if (openStorageImpl)
      await initHive(
        assignStoragePath: assignStoragePath,
        onLocalTestStoragePath: onLocalTestStoragePath,
      );
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
    if (openDialogHelperImpl) await initDI(config.envSign, this);
  }
}

@injectableInit
Future<void> initDI(String env, QuickStartPackage quickStartPackage) async =>
    await $initGetIt(_g, environment: env);
