// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/7/24
// Time  : 17:11

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_arch_core/get_arch_core.dart';

extension GetArchApplicationX on GetArchApplication {
  ///
  /// Flutter App可以使用该方法初始化应用
  /// ```dart
  /// main(){
  ///   await GetArchApplication.flutterRun(...);
  /// }
  /// ```
  /// [masterEnvConfig] App运行的默认环境, [packages]中没有被指定[EnvConfig]的模块都将使用该环境
  /// [run] 即 "runApp();" 的参数
  /// [packages] App所使用的其他GetArch模块
  /// [mockDiAndOtherInitFunc] 供测试时手动注册mock依赖, 或者添加一些自定义初始化的代码
  ///   代码将会在 "GetArchCorePackage.init()"之后, package.init()之前被执行
  /// [printLog] 是否打印配置结果(建议使用默认配置)
  static Future<void> flutterRun(
    EnvConfig masterEnvConfig, {
    @required Widget run,
    List<IGetArchPackage> packages,
    Future<void> Function(GetIt g) mockDiAndOtherInitFunc,
    bool printLog: !kReleaseMode,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetArchApplication.run(
        masterEnvConfig ?? EnvConfig.sign(EnvSign.prod),
        printConfig: printLog,
        packages: packages,
        mockDI: mockDiAndOtherInitFunc);
    if (run != null) runApp(run);
  }
}
