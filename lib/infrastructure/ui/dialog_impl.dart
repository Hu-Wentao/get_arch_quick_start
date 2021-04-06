// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/15
// Time  : 18:08

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_arch_core/domain/failure.dart';
import 'package:get_arch_quick_start/infrastructure/ui/dialog_widget.dart';
import 'package:get_arch_quick_start/interface/i_dialog.dart';
import 'package:get_arch_quick_start/quick_start.dart';

///
/// 本文件依赖于 bot_toast 包

/// 接收Failure, 构建Dialog
typedef FailureDialogBuilder = Widget Function(BuildContext ctx, Failure f);

///
/// 内部存储一个Failure与Dialog的Map
///   例如某处抛出 "未登录Failure", 那么调用[map]中对应的Failure的Dialog
///
/// 这里推荐使用 [QuickAlert]或其继承类作为 Value,
///
/// [map] <Failure类型, Failure所对应的Dialog>
///   Dialog内应当有对应的Failure所应当展示的信息内容,
///   如果有跳转页面需求, 还需要为Dialog按钮的点击回调中
///     添加对应页面跳转逻辑(例如"未登录错误Dialog"可以跳转到 "登录页")
//@lazySingleton 请使用 module或者手动注册本类
class FailureRoute {
  final Map<Type, FailureDialogBuilder> map;

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
class QuickAlert extends AlertDialog {
  QuickAlert({
    Widget title: const Text('提示'),
    Widget? content,
    bool nouseQuickActions = false, // 不使用以下三个参数(不展示此处预设的action按钮)
    List<Widget>? customActions,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  })  : assert(
            ((customActions != null) ^
                    (!(onConfirm == null && onCancel == null))) ||
                (customActions == null &&
                    onConfirm == null &&
                    onCancel == null &&
                    nouseQuickActions),
            '确保左右两边不同,或者全部为null(如果自定义了action,则两个回调也就没有意义了)'),
        super(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: title,
          content: content,
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
          ),
          actions: nouseQuickActions
              ? null
              : customActions ??
                  <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(primary: Colors.red),

                      // highlightColor: const Color(0x55FF8A80),
                      // splashColor: const Color(0x99FF8A80),
                      onPressed: () => onCancel?.call(),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onConfirm?.call(),
                      child: const Text('确定'),
                    ),
                  ],
        );
}

@prod
@test
@LazySingleton(as: IDialog)
class QuickDialog extends IDialog {
  static QuickDialog? _instance;

  static QuickDialog get instance {
    if (_instance == null) _instance = QuickDialog();
    return _instance!;
  }

  static QuickDialog get I => instance;

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
  Future<T?> selectTips<T>({
    required BuildContext ctx,
    String title: '提示',
    Widget? content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    List<Widget>? customActions,
  }) {
    assert(
        (customActions?.length == 0) ^ (onConfirm != null || onCancel != null),
        '隐藏action 与 两个回调方法不全为空 互斥');

    return showDialog<T>(
        context: ctx,
        builder: (ctx) => QuickAlert(
              title: Text('$title'),
              content: content,
              onConfirm: customActions != null
                  ? null
                  : () {
                      // 如果不指定泛型T, 那么就代表 onCancel()方法内已有 Navigator操作
                      //   否则就需要在这里手动pop
                      if (T.toString() == 'void' || T.toString() == 'dynamic')
                        Navigator.pop(ctx);
                      return onConfirm?.call();
                    },
              onCancel: customActions != null
                  ? null
                  : () {
                      if (T.toString() == 'void' || T.toString() == 'dynamic')
                        Navigator.pop(ctx);
                      return onCancel?.call();
                    },
              customActions: customActions,
            ));
  }

  ///
  /// 异常提示
  /// 请在View层使用Dialog, 不要在ViewModel或其他地方使用Dialog!
  ///
  /// 在DI中注册[FailureRoute]后,将会弹出Failure对应的Dialog
  /// [ctx] 不能为空,否则弹出的Dialog无法关闭.
  ///   (当然你也可以实现一个能够在无ctx状态下弹出Dialog并能正常关闭的方案, 但非常不建议这样做)
  /// [tag] 错误标签, 便于Debug
  Future err(dynamic failure, {required BuildContext ctx, dynamic tag}) async {
    assert(ctx != null, 'err中的ctx不能为null!,否则Dialog将无法关闭');
    if (failure is Future) failure = await failure;
    // 必须放在 "is Future"的后面, 否则传输Future<null> 会出错
    if (failure == null) return;
    if (failure is! Failure)
      failure =
          FeedBackUnknownFailure(failure.toString(), tag ?? '无Tag(来自Dialog)');

    if (GetIt.I.isRegistered<FailureRoute>()) {
      final buildDialogFunc = GetIt.I<FailureRoute>().map[failure.runtimeType];
      if (buildDialogFunc != null) {
        if (!kReleaseMode && ctx == null)
          print('\n\nQuickDialog.err# tag[$tag]未添加BuildContext,可能无法正常路由跳转!'
              ' Failure[$failure]\n\n');

        return widget(ctx: ctx, builder: (c) => buildDialogFunc(c, failure));
      }
    } else {
      if (!kReleaseMode) print('QuickDialog.err # 您尚未注册"FailureRoute"!');
    }
    _onNeedFeedback(failure, ctx);
  }

  static _onNeedFeedback(Failure f, BuildContext ctx) => QuickAlert(
        title: Text(f.runtimeType.toString()),
        content: Text(f.msg),
        customActions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(primary: Colors.red),
            // style:ButtonStyle(),
            // highlightColor: const Color(0x55FF8A80),
            // splashColor: const Color(0x99FF8A80),
            child: const Text('Ok'),
          ),
        ],
      );

  @override
  toast(String s, {required BuildContext ctx}) => showDialog(
        context: ctx,
        builder: (c) {
          return TextToast(
            contentPadding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7),
            contentColor: Colors.black54,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            textStyle: const TextStyle(fontSize: 17, color: Colors.white),
            text: s,
          );
        },
      );

  @override
  snack(SnackBar snackBar, {required BuildContext ctx}) =>
      Scaffold.of(ctx).showSnackBar(snackBar);

  /// [ctx] 可选, 添加后性能更好,[ctx]为空则会使用BotToast
  ///
  /// showDialog返回值是 [T],即[dialog]内部通过路由pop()返回的值
  ///
  /// BotToast返回的是 CancelFunc, 调用后可以关闭Dialog,
  ///   如果需要对[dialog]内的操作做出反应,请使用回调函数
  @override
  Future<T?> widget<T>({
    required BuildContext ctx,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) =>
      showDialog<T?>(
          context: ctx,
          builder: builder,
          barrierDismissible: barrierDismissible);
}

@dev
@LazySingleton(as: IDialog)
class DevQuickDialog extends IDialog {
  @override
  err(dynamic failure, {dynamic tag, required BuildContext ctx}) {
    print('''
╔═╣ DevDialog.err | Tag: $tag╠══╗
  $failure
╚══════════════════════════════════════╝
    ''');
  }

  @override
  toast(String s, {required BuildContext ctx}) {
    print('''
╔═╣ DevDialog.text ╠═╗
  $s
╚═══════════════════════════╝
    ''');
  }

  @override
  snack(SnackBar snackBar, {required BuildContext ctx}) {
    print('''
╔═╣ DevDialog.snack ╠═╗
  ${snackBar.toStringDeep()}
╚═══════════════════════════╝
    ''');
  }

  @override
  Future<T?> widget<T>({
    required BuildContext ctx,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    print('''
╔═╣ DevDialog.widget ╠═╗
  Context: [$ctx]
  barrierDismissible: [$barrierDismissible]
  ${builder.call(ctx).toStringDeep()}
╚═══════════════════════════╝
    ''');
    return null;
  }

  @override
  Future<T?> selectTips<T>({
    required BuildContext ctx,
    String title = '提示',
    Widget? content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    List<Widget>? customActions,
  }) async {
    print('''
╔═╣ DevDialog.selectTipsWithCtx ╠═╗
  Context: [$ctx]
  title: [$title]
  content: [$content]
╚═══════════════════════════╝
    ''');
    return null;
  }
}
