// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/15
// Time  : 18:08

import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_arch_core/get_arch_core.dart';

///
/// 本文件依赖于 bot_toast 包

//@prod // 手动注册
//@LazySingleton(as: IDialog)
class QuickDialog extends IDialog {
  static QuickDialog _instance;

  static QuickDialog get instance {
    if (_instance == null) _instance = QuickDialog();
    return _instance;
  }

  ///
  /// [T] 表示pop后返回值的类型
  /// [ctx] 不能使用 AutoRoute提供的context
  /// [noneActions] 为true时,不展示actions
  /// [onConfirm],[onCancel]需要在函数内调用 路由的pop()方法才能返回
  ///   这里没有提供默认的实现, 因为某些路由插件有自己的pop()方法,
  ///   例如auto_route可以直接使用 ExtendedNavigator.rootNavigator.pop(); 进行pop
  Future<T> selectTipsWithCtx<T>({
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
                        onPressed: () => onCancel?.call(),
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      FlatButton(
                        onPressed: () => onConfirm?.call(),
                        child: const Text('确定'),
                      ),
                    ],
            ));
  }

  ///
  /// 尽量使用 [selectTipsWithCtx] 其性能更好
  selectTips({
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

  ///
  /// 异常提示
  err(dynamic failure, [dynamic tag]) {
    if (failure is! Failure)
      failure = UnknownFailure(failure.toString(), tag ?? '来自Dialog');
    switch (failure.runtimeType) {
//      case NotLoginFailure:
//        _onNotLogin(failure);
//        break;
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

  @override
  text(String s) => toast(s);

  @override
  toast(String s) => BotToast.showText(text: s);
}

//@test // 手动注册
//@LazySingleton(as: IDialog)
class TestDialog extends IDialog {
  @override
  err(failure, [tag]) {
    print('''
╔═╣ TestDialog.err | Tag: $tag╠══╗
  $failure
╚══════════════════════════════════════╝
    ''');
  }

  @override
  text(String f) => toast(f);

  @override
  toast(String s) {
    print('''
╔═╣ TestDialog.text ╠═╗
  $s
╚═══════════════════════════╝
    ''');
  }
}

class DevDialog extends TestDialog {}
