// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/8/4
// Time  : 1:02

import 'package:flutter/widgets.dart';
import 'package:get_arch_quick_start/qs_domain.dart';
import 'package:get_arch_quick_start/qs_interface.dart';

///
/// 用于View中快速调用 Dialog.err()
extension DialogX on Failure {
  ///
  /// [T] 通常情况下为 Widget, 如果有需要的话
  errDialog<T>(BuildContext ctx,
      {dynamic tag, String instanceName, IDialog dialog, T returnVal}) {
    if (this != null)
      (dialog ?? GetIt.I<IDialog>(instanceName: instanceName))
          .err(this, ctx: ctx, tag: tag);
    return returnVal;
  }
}

extension FutureDialogX on Future<Failure> {
  asyncErrDialog<T>(BuildContext ctx,
      {dynamic tag, String instanceName, IDialog dialog, T returnVal}) async {
    this?.then((value) => value.errDialog(ctx,
        tag: tag,
        instanceName: instanceName,
        dialog: dialog,
        returnVal: returnVal));
    return returnVal;
  }
}
