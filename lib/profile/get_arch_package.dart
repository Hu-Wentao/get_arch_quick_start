// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 0:44

import 'package:get_arch_core/domain/env_config.dart';
import 'package:get_arch_core/get_arch_part.dart';
import 'package:get_arch_core/interface/i_network.dart';
import 'package:get_arch_core/profile/get_arch_application.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_arch_quick_start/infrastructure/storage_impl.dart';

import 'get_arch_package.iconfig.dart';

part 'profile_module.dart';

INetConfig _httpConfig;
INetConfig _socketConfig;

///
/// [httpConfig] http配置, 如果打算手动i_network,则填null即可
/// [socketConfig] socket配置, 如果打算手动i_network,则填null即可
/// [openStorageAndNetworkImpl] 如果想要手动实现,则设为false
/// [assignStoragePath] Hive的初始化路径,不建议手动配置
/// [onLocalTestStoragePath] Hive本地测试时使用的路径,不建议手动配置
class QuickStartPackage extends IGetArchPackage {
  final bool openStorageAndNetworkImpl;

  final String assignStoragePath;
  final String onLocalTestStoragePath;

  QuickStartPackage({
    INetConfig httpConfig,
    INetConfig socketConfig,
    this.openStorageAndNetworkImpl: true,
    this.assignStoragePath,
    this.onLocalTestStoragePath,
  }) {
    _httpConfig = httpConfig;
    _socketConfig = socketConfig;
  }

  Future<void> initPackage(EnvConfig config) async {
    if (openStorageAndNetworkImpl)
      await initHive(
        assignStoragePath: assignStoragePath,
        onLocalTestStoragePath: onLocalTestStoragePath,
      );
  }

  Future<void> initPackageDI(EnvConfig config) async {
    if (openStorageAndNetworkImpl) await initDI(config.envSign);
  }
}

@injectableInit
Future<void> initDI(String env) async {
  await $initGetIt(GetIt.instance, environment: env);
}
