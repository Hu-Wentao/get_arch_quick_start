// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/8/4
// Time  : 1:02

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/quick_start.dart';

///
/// 用于View中快速调用 Dialog.err()
extension DialogX on Failure {
  ///
  /// 预处理Failure, 可以放在 [errDialog]之前
  /// ```dart
  /// foo().onFailure((f){ ..do sth... return xxx}).errDialog(context);
  /// ```
  Failure mapFailure(Failure Function(Failure f) mapFailure) =>
      mapFailure(this);

  ///
  /// [T] 通常情况下为 Widget, 如果有需要的话
  T errDialog<T>(BuildContext ctx,
      {dynamic tag, String instanceName, IDialog dialog, T returnVal}) {
    if (this != null)
      (dialog ?? GetIt.I<IDialog>(instanceName: instanceName))
          .err(this, ctx: ctx, tag: tag);
    return returnVal;
  }
}

extension FutureDialogX on Future<Failure> {
  Future<Failure> asyncMapFailure(Failure Function(Failure f) mapFailure) =>
      this?.then(mapFailure);

  Future<T> asyncErrDialog<T>(BuildContext ctx,
      {dynamic tag, String instanceName, IDialog dialog, T returnVal}) async {
    this?.then((value) => value.errDialog(ctx,
        tag: tag,
        instanceName: instanceName,
        dialog: dialog,
        returnVal: returnVal));
    return returnVal;
  }
}

///
/// BuildContext扩展
extension BuildContextX on BuildContext {
  MediaQueryData get query => MediaQuery.of(this);

  ThemeData get themeData => Theme.of(this);
}
