// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 0:44

import 'dart:typed_data';

import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_arch_quick_start/infrastructure/storage_impl.dart';
import 'package:get_arch_quick_start/infrastructure/ui/dialog_impl.dart';
import 'package:get_arch_quick_start/interface/i_dialog.dart';
import 'package:get_arch_quick_start/interface/i_network.dart';
import 'package:get_arch_quick_start/interface/i_storage.dart';
import 'package:get_arch_quick_start/quick_start_part.dart';
import 'package:hive/hive.dart';

final _g = GetIt.instance;

final _prod = EnvSign.prod.toString();
final _test = EnvSign.test.toString();
final _dev = EnvSign.dev.toString();
const s_box_name = 'get_arch_quick_start_default_str_box';
const u_box_name = 'get_arch_quick_start_default_uint8_box';
const i_box_name = 'get_arch_quick_start_default_int_box';

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
    this.openStorageImpl: true,
    this.assignStoragePath,
    this.onLocalTestStoragePath: './_hive_test_cache',
    this.openDialogImpl: true,
  })  : assert(openStorageImpl != null),
        assert(openDialogImpl != null),
        super(pkgEnvConfig);

  @override
  Map<Type, bool> get interfaceImplRegisterStatus => {
        IHttp: httpConfig != null,
        ISocket: socketConfig != null,
        IStorage: openStorageImpl,
        IDialog: openDialogImpl,
      };
  @override
  Map<String, String> printOtherStateWithEnvConfig(EnvConfig config) => {
        'IHttp': '配置为: ${httpConfig ?? '当前未开启IHttp!'}',
        'ISocket': '配置为: ${socketConfig ?? '当前未开启ISocket!'}',
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
    final _gh = GetItHelper(_g, config.envSign.toString());

    if (httpConfig != null) {
      _gh.lazySingleton<HttpConfig>(() => httpConfig);
      _gh.lazySingleton<IHttp>(() => HttpImpl(_g<HttpConfig>()));
    }

    if (socketConfig != null) {
      _gh.lazySingleton<SocketConfig>(() => socketConfig);
      _gh.lazySingleton<ISocket>(() => SocketImpl(_g<SocketConfig>()));
    }
    // 这里将Box注册为<String>, 存储对象的json字符串, 一般情况下性能与TypeAdapter区别不大
    // 使用TypeAdapter,每个类型都需要不同的id, 在使用多个package的情况下极易出错
    if (openStorageImpl) {
      final strBox = await Hive.openBox<String>(s_box_name);
      final u8Box = await Hive.openBox<Uint8List>(u_box_name);
      final intBox = await Hive.openBox<int>(i_box_name);
      _gh.lazySingleton<Box<String>>(() => strBox);
      _gh.lazySingleton<Box<Uint8List>>(() => u8Box);
      _gh.lazySingleton<Box<int>>(() => intBox);
      _gh.lazySingleton<IStorage>(() => StorageImpl(
            _g<Box<String>>(),
            _g<Box<Uint8List>>(),
            _g<Box<int>>(),
          ));
    }
    if (openDialogImpl) await initDialog(_gh);
  }
}

// 由于当前只有Dialog被自动注册, 因此这里直接调用 initDI
initDialog(GetItHelper g) {
  g.lazySingleton<IDialog>(() => QuickDialog(), registerFor: {_test, _prod});
  g.lazySingleton<IDialog>(() => DevQuickDialog(), registerFor: {_dev});
}

// 通过以下代码借助build_runner生成DI代码, 生成完毕后将需要的代码复制到quick_start_package.dart
// 以便通过参数控制依赖的注册
//@injectableInit
//Future<void> initDI({@required String env}) async {
//  $initGetIt(GetIt.I, environment: env);
//}
