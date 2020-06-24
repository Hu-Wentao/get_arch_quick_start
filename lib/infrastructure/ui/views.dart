// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/5/9
// Time  : 21:37
import 'package:flutter/material.dart';

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
