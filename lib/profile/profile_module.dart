// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/17
// Time  : 13:10

part of 'get_arch_package.dart';

@module
abstract class ProfileModule {
  @Named(k_http_config)
  INetConfig get httpConfig => _httpConfig;
  @Named(k_socket_config)
  INetConfig get socketConfig => _socketConfig;
}
