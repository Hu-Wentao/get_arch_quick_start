// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:hive/hive.dart';
import 'package:get_arch_quick_start/infrastructure/storage_impl.dart';
import 'package:get_arch_quick_start/infrastructure/ui/dialog_helper_impl.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/profile/get_arch_package.dart';
import 'package:get_arch_core/interface/i_network.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_arch_core/interface/i_storage.dart';
import 'package:get_it/get_it.dart';

Future<void> $initGetIt(GetIt g, {String environment}) async {
  final registerHiveBox = _$RegisterHiveBox();
  final profileQuickStart = _$ProfileQuickStart();
  final box = await registerHiveBox.defaultBox;
  g.registerFactory<Box<String>>(() => box);
  g.registerFactory<INetConfig>(() => profileQuickStart.httpConfig,
      instanceName: 'k_http_config');
  g.registerFactory<INetConfig>(() => profileQuickStart.socketConfig,
      instanceName: 'k_socket_config');
  g.registerLazySingleton<ISocket>(
      () => SocketImpl(g<INetConfig>(instanceName: 'k_socket_config')));
  g.registerLazySingleton<IStorage>(() => StorageImpl(g<Box<String>>()));
  g.registerLazySingleton<IHttp>(
      () => HttpImpl(g<INetConfig>(instanceName: 'k_http_config')));

  //Register prod Dependencies --------
  if (environment == 'prod') {
    g.registerLazySingleton<IDialogHelper>(() => DialogHelper());
  }

  //Register test Dependencies --------
  if (environment == 'test') {
    g.registerLazySingleton<IDialogHelper>(() => TestDialogHelper());
  }

  //Register dev Dependencies --------
  if (environment == 'dev') {
    g.registerLazySingleton<IDialogHelper>(() => DevDialogHelper());
  }
}

class _$RegisterHiveBox extends RegisterHiveBox {}

class _$ProfileQuickStart extends ProfileQuickStart {}
