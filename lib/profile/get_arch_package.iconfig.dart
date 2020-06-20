// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_arch_quick_start/infrastructure/ui/dialog_helper_impl.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  //Register prod Dependencies --------
  if (environment == 'prod') {
    g.registerLazySingleton<IDialogHelper>(() => QuickDialogHelper());
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
