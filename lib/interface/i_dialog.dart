// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/22
// Time  : 23:18

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// 对话框接口
/// 前两个方法都是无context参数方法,
///   一般使用bot_toast,ok_toast来实现, 建议只用于展示异常与debug调试
/// 普通dialog推荐使用带context的原生实现, 性能更好
///
/// 注意!
///   本类方法尽可能放在View中调用, 不要将View的Context传到ViewModel中调用IDialog的方法
///   (toast可以放在ViewModel中调用)
abstract class IDialog {
  ///
  /// 错误处理
  /// <返回值为dynamic,不要修改为void,否则无法通过Either.fold中的代码检查>
  /// 注意: 如果err弹出的Dialog有路由跳转的需求, 那么[ctx]不能为空
  ///   (如果是使用其他无需ctx的Navigator,则需要手动配置路由pop方法)
  err(dynamic failure, {dynamic tag, required BuildContext ctx});

  /// Toast
  /// [ctx] toast不强制要求上下文, 因为toast没有页面跳转的需求.
  toast(String s, {required BuildContext ctx});

  ///
  /// 展示SnackBar, 请确保在使用时,其parent中有[Scaffold]
  snack(SnackBar snackBar, {required BuildContext ctx});

  /// 展示Dialog
  /// (无 ctx 的对话框不能直接接受返回值, 但可以通过回调的方式获得返回值)
  Future<T?> widget<T>({
    required BuildContext ctx,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  });

  ///
  /// 展示带有两个Action(确认,取消) 的Dialog
  /// [ctx] 上下文,可以用于Widget构建与路由跳转
  /// [title] Dialog的标题
  /// [content] Dialog的内容
  /// [onConfirm] 当点击了默认的"确认"按钮后
  /// [onCancel] 当点击了默认的"取消"按钮后
  ///
  /// [customActions] 自定义Actions,该参数与 [onConfirm]和 [onCancel]互斥
  Future<T?> selectTips<T>({
    required BuildContext ctx,
    String title: '提示',
    Widget? content,
    required VoidCallback onConfirm,
    VoidCallback onCancel,
    List<Widget> customActions,
  });
}
