// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/15
// Time  : 18:08

import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:injectable/injectable.dart';

///
/// 本文件依赖于 bot_toast 包

@prod
@LazySingleton(as: IDialogHelper)
class DialogHelper extends IDialogHelper {
  static DialogHelper _instance;

  static DialogHelper get instance {
    if (_instance == null) _instance = DialogHelper();
    return _instance;
  }

  static Function() popFunc = () => ExtendedNavigator.rootNavigator.pop();

  ///
  /// [T] 表示pop后返回值的类型
  /// [ctx] 不能使用 AutoRoute提供的context
  /// [noneActions] 为true时,不展示actions
  static Future<T> selectTipsWithCtx<T>({
    @required BuildContext ctx,
    String title: '提示',
    @required Widget content,
    @required VoidCallback onConfirm,
    VoidCallback onCancel,
    bool noneActions,
  }) {
    // 当noneActions为null, 且两个回调都为null时,为noneAction赋true,否则为false
    noneActions ??= (onConfirm == null && onCancel == null);
    // 确保 ^ 左右两边不同
    assert(noneActions ^ !(onConfirm == null && onCancel == null),
        '当noneActions==true时, 两个callBack必须为null');
    return showDialog<T>(
        context: ctx,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              title: Text('$title'),
              content: content,
              contentPadding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
              ),
              actions: noneActions
                  ? null
                  : <Widget>[
                      FlatButton(
                        highlightColor: const Color(0x55FF8A80),
                        splashColor: const Color(0x99FF8A80),
                        onPressed: () {
                          // 如果不指定泛型T, 那么就代表 onCancel()方法内已有 Navigator操作
                          if (T.toString() == 'void' ||
                              T.toString() == 'dynamic') popFunc();
                          onCancel?.call();
                        },
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (T.toString() == 'void' ||
                              T.toString() == 'dynamic') popFunc();
                          onConfirm?.call();
                        },
                        child: const Text('确定'),
                      ),
                    ],
            ));
  }

  ///
  /// 尽量使用 [selectTipsWithCtx] 其性能更好
  static selectTips({
    String title: '提示',
    @required Widget content,
    @required VoidCallback onConfirm,
    VoidCallback onCancel,
  }) {
    BotToast.showWidget(
        toastBuilder: (cancelFunc) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              title: Text('$title'),
              content: content,
              contentPadding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    cancelFunc();
                    onCancel?.call();
                  },
                  highlightColor: const Color(0x55FF8A80),
                  splashColor: const Color(0x99FF8A80),
                  child: const Text(
                    '取消',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    cancelFunc();
                    onConfirm?.call();
                  },
                  child: const Text('确定'),
                ),
              ],
            ));
  }

  static staticOnErr(dynamic failure) => instance.err(failure);

  ///
  /// 异常提示
  err(dynamic failure) {
    if (failure is! Failure) failure = UnknownFailure(failure.toString());
    switch (failure.runtimeType) {
      case NotLoginFailure:
        _onNotLogin(failure);
        break;
      case NeedFeedbackMx:
        _onNeedFeedback(failure); //  TODO 如,NeedFeedbackFailure就添加 "立即反馈" 按钮
        break;
      default: // 未知异常也使用 NeedFeedback
        _onNeedFeedback(failure);
    }
  }

  static _onNeedFeedback(Failure f) => BotToast.showWidget(
      toastBuilder: (cancelFunc) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text(f.runtimeType.toString()),
            content: Text(f.msg),
            actions: <Widget>[
              FlatButton(
                onPressed: () => cancelFunc(),
                highlightColor: const Color(0x55FF8A80),
                splashColor: const Color(0x99FF8A80),
                child: const Text('Ok'),
              ),
            ],
          ));

  static _onNotLogin(f) => BotToast.showWidget(
      toastBuilder: (cancelFunc) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text('提示'),
            content: Text('请登陆后继续'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => cancelFunc(),
                highlightColor: const Color(0x55FF8A80),
                splashColor: const Color(0x99FF8A80),
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              FlatButton(
                onPressed: () {
                  cancelFunc();
//                      // 跳转到登陆页 fixme: 这里代码耦合了
//                      ExtendedNavigator.ofRouter<Router>()
//                          .pushNamed(Routes.authPage);
                },
                child: const Text('确定'),
              ),
            ],
          ));

  @override
  text(String s) => BotToast.showText(text: s);
}

@test
@LazySingleton(as: IDialogHelper)
class TestDialogHelper extends IDialogHelper {
  @override
  err(failure) {
    print('''
╔═╣ TestDialogHelper.err ╠══╗
  $failure
╚═══════════════════════════╝
    ''');
  }

  @override
  text(String f) {
    print('''
╔═╣ TestDialogHelper.text ╠═╗
  $f
╚═══════════════════════════╝
    ''');
  }
}

@dev
@LazySingleton(as: IDialogHelper)
class DevDialogHelper extends TestDialogHelper {}
