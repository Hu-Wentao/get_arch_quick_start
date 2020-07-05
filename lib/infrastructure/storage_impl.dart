// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/16
// Time  : 23:26

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get_arch_quick_start/interface/i_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive({
  String assignStoragePath,
  String onLocalTestStoragePath,
}) async {
  var path;

  if (assignStoragePath != null) {
    path = assignStoragePath;
  } else {
    try {
      path = (await getApplicationDocumentsDirectory()).path;
    } on MissingPluginException {
      path = onLocalTestStoragePath;
    }
  }
  Hive.init(path);
}

//@LazySingleton(as: IStorage) // 手动注册
class StorageImpl extends IStorage {
  final Box<String> strBox;
  final Box<Uint8List> u8Box;
  final Box<int> intBox;

  StorageImpl(this.strBox, this.u8Box, this.intBox);

  @override
  int getInt(String key) => intBox.get(key);

  @override
  void setInt(String key, int value) async => await intBox.put(key, value);

  @override
  Uint8List getUint8List(String key) => u8Box.get(key);

  @override
  void setUint8List(String key, Uint8List value) async =>
      await u8Box.put(key, value);
  @override
  String getData(String key) => strBox.get(key);

  @override
  Future<void> setData(String key, String value) async =>
      await strBox.put(key, value);

  @override
  void setJson(String key, Map<String, dynamic> js) =>
      setData(key, json.encode(js));

  @override
  Map<String, dynamic> getJson(String key) {
    final r = getData(key);
    if (r == null) return null;
    return json.decode(r);
  }
}
