// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/13
// Time  : 20:40

import 'dart:typed_data';

///
/// 本地存储接口
abstract class IStorage {
  /// 读取 String
  String? getData(String key);

  /// 写入 String
  void setData(String key, String value);

  /// 读取 Uint8List
  Uint8List? getUint8List(String key);

  /// 写入 Uint8List
  void setUint8List(String key, Uint8List value);

  /// 读取 int
  int? getInt(String key);

  /// 写入 int
  void setInt(String key, int value);

  Map<String, dynamic>? getJson(String key);

  void setJson(String key, Map<String, dynamic> js);
}
