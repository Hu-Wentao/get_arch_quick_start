// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/16
// Time  : 23:26

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get_arch_core/get_arch_part.dart';
import 'package:get_arch_core/interface/i_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// 注册HiveBox
@module
abstract class RegisterHiveBox {
  @preResolve
  Future<Box<String>> get defaultBox => Hive.openBox<String>('default_box');
}

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
      path = onLocalTestStoragePath ?? './_hive_test_cache';
    }
  }
  Hive.init(path);
}

class StorageImpl extends IStorage {
  final Box<String> box;

  StorageImpl(this.box);

  @override
  Future<void> setData(String key, String value) async =>
      await box.put(key, value);
  @override
  String getData(String key) => box.get(key);

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
