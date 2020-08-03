// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/get_it_helper.dart';

import '../interface/i_dialog.dart';
import '../infrastructure/ui/dialog_impl.dart';

/// Environment names
const _prod = 'prod';
const _test = 'test';
const _dev = 'dev';

/// adds generated dependencies
/// to the provided [GetIt] instance

void $initGetIt(GetIt g, {String environment}) {
  final gh = GetItHelper(g, environment);
  gh.lazySingleton<IDialog>(() => QuickDialog(), registerFor: {_test, _prod});
  gh.lazySingleton<IDialog>(() => DevQuickDialog(), registerFor: {_dev});
}
