// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 0:44

import 'dart:typed_data';

import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/infrastructure/ui/dialog_impl.dart';
import 'package:get_arch_quick_start/interface/i_dialog.dart';
import 'package:get_arch_quick_start/interface/i_network.dart';
import 'package:get_arch_quick_start/interface/i_storage.dart';
import 'package:get_arch_quick_start/quick_start_part.dart';

final _g = GetIt.instance;

final _prod = EnvSign.prod.inString;
final _test = EnvSign.test.inString;
final _dev = EnvSign.dev.inString;
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
  @Deprecated('实现已移除')
  final INetConfig? httpConfig;
  @Deprecated('实现已移除')
  final INetConfig? socketConfig;
  @Deprecated('实现已移除')
  final bool openStorageImpl;
  final String? assignStoragePath;
  final String onLocalTestStoragePath;
  final bool openDialogImpl;

  QuickStartPackage({
    EnvConfig? pkgEnvConfig,
    this.httpConfig,
    this.socketConfig,
    this.openStorageImpl: true,
    this.assignStoragePath,
    this.onLocalTestStoragePath: './_hive_test_cache',
    this.openDialogImpl: true,
  }) : super(pkgEnvConfig);

  @override
  Map<Type, bool> get interfaceImplRegisterStatus => {
        IHttp: httpConfig != null,
        ISocket: socketConfig != null,
        IStorage: openStorageImpl,
        IDialog: openDialogImpl,
      };
  @override
  Map<String, String>? printOtherStateWithEnvConfig(EnvConfig? config) => {
        'IHttp': '配置为: ${httpConfig ?? '当前未开启IHttp!'}',
        'ISocket': '配置为: ${socketConfig ?? '当前未开启ISocket!'}',
        'IStorage':
            '配置路径: ${assignStoragePath ?? '默认[getApplicationDocumentsDirectory()]'}'
                '\n  本地测试时使用的路径: $onLocalTestStoragePath',
      };

  Future<void> initPackage(EnvConfig config) async {}

  Future<void>? initPackageDI(EnvConfig config,
      {EnvironmentFilter? filter}) async {
    final gh = GetItHelper(
        _g, filter != null ? null : config.envSign.inString, filter);

    if (openDialogImpl) await initDialog(gh);
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
//Future<void> initDI({required String env}) async {
//  $initGetIt(GetIt.I, environment: env);
//}
