// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/15
// Time  : 18:08

import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/domain/error/failures.dart';
import 'package:get_arch_quick_start/interface/i_dialog.dart';
import 'package:get_arch_quick_start/quick_start.dart';
import 'package:get_arch_quick_start/quick_start_part.dart';

///
/// 本文件依赖于 bot_toast 包

///
/// 内部存储一个Failure与Dialog的Map
///   例如某处抛出 "未登录Failure", 那么调用[map]中对应的Failure的Dialog
///
/// 这里推荐使用 [QuickAlter]或其继承类作为 Value,
///
/// [map] <错误类型, 错误所对应的Dialog>
///   Dialog内应当有对应的Failure所应当展示的信息内容,
///   如果有跳转页面需求, 还需要为Dialog按钮的点击回调中
///     添加对应页面跳转逻辑(例如"未登录错误Dialog"可以跳转到 "登录页")
//@lazySingleton 请使用 module或者手动注册本类
class FailureRoute {
  final Map<Failure, Widget> map;

  FailureRoute(this.map);
}

///
/// 对话框模板, 用于快速构建对话框
///
/// [title] Dialog的标题
/// [content] Dialog的内容
/// [customActions] 与 [onCancel],[onConfirm]互斥
/// [onConfirm] "确认"按钮回调
/// [onCancel]  "取消"按钮回调
class QuickAlter extends AlertDialog {
  QuickAlter({
    Widget title: const Text('提示'),
    Widget content,
    List<Widget> customActions,
    VoidCallback onConfirm,
    VoidCallback onCancel,
  })  : assert(
            (customActions != null) ^
                (!(onConfirm == null && onCancel == null)),
            '确保左右两边不同(如果自定义了action,则两个回调也就没有意义了)'),
        super(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: title,
          content: content,
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
          ),
          actions: customActions ??
              <Widget>[
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
        );
}

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
  /// [onConfirm],[onCancel]需要在函数内调用 路由的pop()方法才能返回
  ///   这里没有提供默认的实现, 因为某些路由插件有自己的pop()方法,
  ///   例如auto_route可以直接使用 ExtendedNavigator.rootNavigator.pop(); 进行pop
  ///
  /// [customActions] 自定义Action,
  ///   值为null时, Dialog将会有两个默认的"确认"和"取消"按钮,
  ///   值为[] 时, 将隐藏 action按钮
  Future<T> selectTipsWithCtx<T>({
    @required BuildContext ctx,
    String title: '提示',
    @required Widget content,
    @required VoidCallback onConfirm,
    VoidCallback onCancel,
    List<Widget> customActions,
  }) {
    assert(ctx != null, '请填写ctx! 如果无法提供BuildContext,请使用 selectTips()');
    assert(
        (customActions?.length == 0) ^ (onConfirm != null || onCancel != null),
        '隐藏action 与 两个回调方法不全为空 互斥');

    return showDialog<T>(
        context: ctx,
        builder: (ctx) => QuickAlter(
              title: Text('$title'),
              content: content,
              onConfirm: () {
                // 如果不指定泛型T, 那么就代表 onCancel()方法内已有 Navigator操作
                //   否则就需要在这里手动pop
                if (T.toString() == 'void' || T.toString() == 'dynamic')
                  Navigator.pop(ctx);
                return onConfirm?.call();
              },
              onCancel: () {
                if (T.toString() == 'void' || T.toString() == 'dynamic')
                  Navigator.pop(ctx);
                return onCancel?.call();
              },
              customActions: customActions,
            ));
  }

  ///
  /// 尽量使用 [selectTipsWithCtx] 其性能更好
  selectTips({
    String title: '提示',
    @required Widget content,
    @required VoidCallback onConfirm,
    VoidCallback onCancel,
  }) =>
      BotToast.showWidget(
          toastBuilder: (cancelFunc) => QuickAlter(
                title: Text('$title'),
                content: content,
                onConfirm: () {
                  cancelFunc();
                  return onConfirm?.call();
                },
                onCancel: () {
                  cancelFunc();
                  return onCancel?.call();
                },
              ));

  ///
  /// 异常提示
  /// 在DI中注册[FailureRoute]后,将会弹出Failure对应的Dialog
  err(dynamic failure, {BuildContext ctx, dynamic tag}) {
    if (failure is! Failure)
      failure = FeedBackUnknownFailure(failure.toString(), tag ?? '来自Dialog');
    final r = GetIt.I.isRegistered<FailureRoute>();
    if (r) {
      if (!kReleaseMode) print('QuickDialog.err # 您尚未注册"FailureRoute"!');
    } else {
      final dialog = GetIt.I<FailureRoute>().map[failure];
      if (dialog != null) {
        return widget(ctx: ctx, dialog: dialog);
      }
    }
    _onNeedFeedback(failure);
  }

  static _onNeedFeedback(Failure f) => BotToast.showWidget(
      toastBuilder: (cancelFunc) => QuickAlter(
            title: Text(f.runtimeType.toString()),
            content: Text(f.msg),
            customActions: <Widget>[
              FlatButton(
                onPressed: () => cancelFunc(),
                highlightColor: const Color(0x55FF8A80),
                splashColor: const Color(0x99FF8A80),
                child: const Text('Ok'),
              ),
            ],
          ));

  @override
  toast(String s, {BuildContext ctx}) => ctx != null
      ? snack(
          ctx: ctx, content: Text('$s'), behavior: SnackBarBehavior.floating)
      : BotToast.showText(text: s);

  @override
  snack({
    @required BuildContext ctx,
    @required Widget content,
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    SnackBarBehavior behavior,
    SnackBarAction action,
    Duration duration,
    Animation<double> animation,
    VoidCallback onVisible,
  }) =>
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        behavior: behavior,
        action: action,
        duration: duration,
        animation: animation,
        onVisible: onVisible,
      ));

  /// [ctx] 可选, 一般推荐加上,[ctx]为空则会使用BotToast
  ///
  /// showDialog返回值是 [T],即[dialog]内部通过路由pop()返回的值
  ///
  /// BotToast返回的是 CancelFunc, 调用后可以关闭Dialog,
  ///   如果需要对[dialog]内的操作做出反应,请使用回调函数
  @override
  widget<T>({BuildContext ctx, Widget dialog}) => ctx == null
      ? BotToast.showWidget(toastBuilder: (_) => dialog)
      : showDialog<T>(context: ctx, builder: (ctx) => dialog);
}

//@test // 手动注册
//@LazySingleton(as: IDialog)
class TestDialog extends IDialog {
  @override
  err(dynamic failure, {dynamic tag, BuildContext ctx}) {
    print('''
╔═╣ TestDialog.err | Tag: $tag╠══╗
  $failure
╚══════════════════════════════════════╝
    ''');
  }

  @override
  toast(String s, {BuildContext ctx}) {
    print('''
╔═╣ TestDialog.text ╠═╗
  $s
╚═══════════════════════════╝
    ''');
  }

  @override
  snack(
      {BuildContext ctx,
      Widget content,
      Color backgroundColor,
      double elevation,
      ShapeBorder shape,
      SnackBarBehavior behavior,
      SnackBarAction action,
      Duration duration,
      Animation<double> animation,
      onVisible}) {
    print('''
╔═╣ Test/DevDialog.snack ╠═╗
  ${content.toStringDeep()}
╚═══════════════════════════╝
    ''');
  }

  @override
  widget<T>({BuildContext ctx, Widget dialog}) {
    print('''
╔═╣ Test/DevDialog.widget ╠═╗
  Context: [$ctx]
  ${dialog.toStringDeep()}
╚═══════════════════════════╝
    ''');
  }
}

class DevDialog extends TestDialog {}
