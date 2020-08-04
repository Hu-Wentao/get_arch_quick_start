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
  errDialog(BuildContext ctx, {dynamic tag, String instanceName}) {
    GetIt.I<IDialog>(instanceName: instanceName).err(this, ctx: ctx, tag: tag);
  }
}

extension FutureDialogX on Future<Failure> {
  errDialog(BuildContext ctx, {dynamic tag, String instanceName}) async {
    GetIt.I<IDialog>(instanceName: instanceName).err(this, ctx: ctx, tag: tag);
  }
}
