// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/5/9
// Time  : 21:37

// @dart=2.9

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'extension.dart';

/// 由 Chip 构成了列表, 可以自定义排列方向
/// [tapEnabled] 按钮是否启用, null表示全部可用
class ChipBar<DATA> extends StatelessWidget {
  final Axis direction;
  final int selectIndex;
  final List<DATA> dataList;
  final List<bool> tapEnabled;
  final Widget Function(int i, DATA data) buildLabel;
  final Function(int index, bool selected) onSelected;

  const ChipBar({
    Key key,
    this.direction: Axis.horizontal,
    this.tapEnabled,
    @required this.selectIndex,
    @required this.dataList,
    @required this.buildLabel,
    @required this.onSelected,
  })  : assert(tapEnabled == null || tapEnabled.length == dataList.length,
            '按钮开关状态必须与数据源长度匹配!'),
        super(key: key);

  @override
  Widget build(BuildContext context) => Flex(
        direction: direction,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<RawChip>.generate(
            dataList.length,
            (i) => RawChip(
                  tapEnabled: tapEnabled == null ? true : tapEnabled[i],
                  label: buildLabel(i, dataList[i]),
                  selected: selectIndex == i,
                  onSelected: (b) => onSelected(i, b),
                )),
      );
}

/// Customized appbar.
/// 自定义的顶栏。
class FixedAppBar extends StatelessWidget {
  const FixedAppBar({
    Key key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.automaticallyImplyActions = true,
    this.backgroundColor,
    this.elevation = 2.0,
    this.actions,
    this.actionsPadding,
    this.height,
    this.blurRadius = 0.0,
  }) : super(key: key);

  /// Title widget.
  /// 标题部件
  final Widget title;

  /// Leading widget.
  /// 头部部件
  final Widget leading;

  /// Action widgets.
  /// 尾部操作部件
  final List<Widget> actions;

  /// Padding for actions.
  /// 尾部操作部分的内边距
  final EdgeInsetsGeometry actionsPadding;

  /// Whether it should imply leading with [BackButton] automatically.
  /// 是否会自动检测并添加返回按钮至头部
  final bool automaticallyImplyLeading;

  /// Whether the [title] should be at the center of the [FixedAppBar].
  /// [title] 是否会在正中间
  final bool centerTitle;

  /// Whether it should imply actions size with [kMinInteractiveDimension].
  /// 是否会自动使用[kMinInteractiveDimension]进行占位
  final bool automaticallyImplyActions;

  /// Background color.
  /// 背景颜色
  final Color backgroundColor;

  /// The size of the shadow below the app bar.
  /// 底部阴影的大小
  final double elevation;

  /// Height of the app bar.
  /// 高度
  final double height;

  /// Value that can enable the app bar using filter with [ui.ImageFilter]
  /// 实现高斯模糊效果的值
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    Widget _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }
    AppBar();
    Widget child = Container(
      width: context.query.size.width,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: (height ?? kToolbarHeight) + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        boxShadow: elevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0x0d000000),
                  blurRadius: elevation * 1.0,
                  offset: Offset(0, elevation * 2.0),
                ),
              ]
            : null,
        color: (backgroundColor ?? Theme.of(context).primaryColor)
            .withOpacity(blurRadius > 0.0 ? 0.90 : 1.0),
      ),
      child: Stack(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop())
            PositionedDirectional(
              top: 0.0,
              bottom: 0.0,
              start: 0.0,
              width: kMinInteractiveDimension,
              child: leading ?? const BackButton(),
            ),
          if (_title != null)
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: automaticallyImplyLeading && Navigator.of(context).canPop()
                  ? kMinInteractiveDimension
                  : 0.0,
              right: automaticallyImplyActions ? kMinInteractiveDimension : 0.0,
              child: Align(
                alignment: centerTitle
                    ? Alignment.center
                    : AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  child: _title,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontSize: 23.0,
                        fontWeight: FontWeight.normal,
                      ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              (actions?.isEmpty ?? true))
            const SizedBox(width: kMinInteractiveDimension)
          else if (actions?.isNotEmpty ?? false)
            PositionedDirectional(
              top: 0.0,
              bottom: 0.0,
              end: 0.0,
              child: Padding(
                padding: actionsPadding ?? EdgeInsets.zero,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
        ],
      ),
    );
    if (blurRadius > 0.0) {
      child = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: child,
        ),
      );
    }
    return Material(type: MaterialType.transparency, child: child);
  }
}

/// Wrapper for [FixedAppBar]. Avoid elevation covered by body.
/// 顶栏封装。防止内容块层级高于顶栏导致遮挡阴影。
class FixedAppBarWrapper extends StatelessWidget {
  const FixedAppBarWrapper({
    Key key,
    @required this.appBar,
    @required this.body,
  })  : assert(
          appBar != null && body != null,
          'All fields must not be null.',
        ),
        super(key: key);

  final FixedAppBar appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: body,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: appBar,
          ),
        ],
      ),
    );
  }
}
