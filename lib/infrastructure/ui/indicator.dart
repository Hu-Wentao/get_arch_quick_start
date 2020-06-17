// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/5/23
// Time  : 22:09

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/widgets.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///
/// Header 刷新动画 <使用GIF>
class GifHeader extends RefreshIndicator {
  final AssetImage gifImg;

  GifHeader(this.gifImg)
      : super(height: 80.0, refreshStyle: RefreshStyle.Follow);

  @override
  State<StatefulWidget> createState() => GifHeaderState();
}

class GifHeaderState extends RefreshIndicatorState<GifHeader>
    with SingleTickerProviderStateMixin {
  GifController _gifCtrl;

  @override
  void initState() {
    // init frame is 2
    _gifCtrl = GifController(
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus mode) {
    if (mode == RefreshStatus.refreshing) {
      _gifCtrl.repeat(min: 0, max: 29, period: Duration(milliseconds: 500));
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    _gifCtrl.value = 30;
    return _gifCtrl.animateTo(59, duration: Duration(milliseconds: 500));
  }

  @override
  void resetValue() {
    // reset not ok , the plugin need to update lowwer
    _gifCtrl.value = 0;
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return GifImage(
      image: widget.gifImg,
      controller: _gifCtrl,
      height: 80.0,
      width: 537.0,
    );
  }

  @override
  void dispose() {
    _gifCtrl.dispose();
    super.dispose();
  }
}

///
/// Footer 刷新动画 <使用GiF>
class GifFooter extends StatefulWidget {
  final AssetImage gifImg;

  GifFooter(this.gifImg) : super();

  @override
  State<StatefulWidget> createState() {
    return _GifFooterState();
  }
}

class _GifFooterState extends State<GifFooter>
    with SingleTickerProviderStateMixin {
  GifController _gifController;

  @override
  void initState() {
    // init frame is 2
    _gifController = GifController(
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      height: 80,
      builder: (context, mode) {
        return GifImage(
          image: widget.gifImg,
          controller: _gifController,
          height: 80.0,
          width: 537.0,
        );
      },
      loadStyle: LoadStyle.ShowWhenLoading,
      onModeChange: (mode) {
        if (mode == LoadStatus.loading) {
          _gifController.repeat(
              min: 0, max: 29, period: Duration(milliseconds: 500));
        }
      },
      endLoading: () async {
        _gifController.value = 30;
        return _gifController.animateTo(59,
            duration: Duration(milliseconds: 500));
      },
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }
}
