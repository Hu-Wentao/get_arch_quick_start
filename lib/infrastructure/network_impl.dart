// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/13
// Time  : 15:09

import 'package:get_arch_quick_start/interface/i_network.dart';

/// HttpImpl 使用的INetConfig类型
@Deprecated('直接使用INetConfig')
class HttpConfig extends INetConfig {
  HttpConfig(
      String scheme, String authority, Map<String, String>? staticHeaders)
      : super(scheme, authority, staticHeaders);
}

/// SocketImpl 使用的INetConfig类型
@Deprecated('直接使用INetConfig')
class SocketConfig extends INetConfig {
  SocketConfig(
      String scheme, String authority, Map<String, String>? staticHeaders)
      : super(scheme, authority, staticHeaders);
}
