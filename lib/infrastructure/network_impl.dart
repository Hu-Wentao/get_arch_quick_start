// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/13
// Time  : 15:09

// @dart=2.9

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/interface/i_network.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// HttpImpl 使用的INetConfig类型
class HttpConfig extends INetConfig {
  HttpConfig(String scheme, String authority, Map<String, String> staticHeaders)
      : super(scheme, authority, staticHeaders);
}

/// SocketImpl 使用的INetConfig类型
class SocketConfig extends INetConfig {
  SocketConfig(
      String scheme, String authority, Map<String, String> staticHeaders)
      : super(scheme, authority, staticHeaders);
}

/// 已手动注册 @LazySingleton(as: IHttp)
///
/// [HttpImpl] 只提供基础功能实现,
/// 如果要获取http statue code,并进行一些操作, 请自行实现[IHttp]
/// 或继承[HttpImpl],在构造中添加自定义拦截器
///
/// 注意, 这 handleRequest(), get(), post()等方法返回的是Dio中的Response实例的 .data属性值
class HttpImpl extends IHttp {
  @protected
  final Dio dio;
  @override
  HttpConfig config;

  HttpImpl(this.config)
      : dio = Dio(
          BaseOptions(
              baseUrl: config.baseUrl,
              // 这里的[staticHeaders]可能为immutable,因此需要 Map.from()
              headers: config.staticHeaders == null
                  ? {}
                  : Map.from(config.staticHeaders)),
        )..interceptors.addAll([
            if (!kReleaseMode)
              PrettyDioLogger(
                request: false,
                requestHeader: true,
                requestBody: true,
              ),
          ]);

  @override
  Future handleRequest(
    String type,
    String tailUrl, {
    IDto dataDto,
    Map<String, dynamic> queryParameters,
    dynamic data,
  }) async =>
      _dioReqAdapter(type, tailUrl,
          dataDto: dataDto,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            method: type,
          ));

  @override
  Future<Uint8List> handleBytesRequest(String type, String tailUrl,
          {IDto dataDto, Map<String, dynamic> queryParameters, data}) async =>
      await _dioReqAdapter(type, tailUrl,
          dataDto: dataDto,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            method: type,
            responseType: ResponseType.bytes,
          ));

  _dioReqAdapter(
    String type,
    String tailUrl, {
    @required IDto dataDto,
    @required Map<String, dynamic> queryParameters,
    @required dynamic data,
    @required Options options,
  }) async =>
      (await dio.request(
        tailUrl,
        options: options,
        data: data ?? dataDto?.toJson(),
        queryParameters: queryParameters,
      ))
          .data;
}

/// 已手动注册 @LazySingleton(as: ISocket)
/// 实现了基本的socket管理功能
class SocketImpl extends ISocket {
  @override
  final SocketConfig config;
  Map<String, ISocketController> socketMap = <String, ISocketController>{};

  SocketImpl(this.config);

  Future<ISocketController> handleWebSocket(
      String tailUrl, void Function() onClose) async {
    final uri = Uri.parse(config.baseUrl + tailUrl);
    return SocketCtrlImpl(WebSocketChannel.connect(uri), onClose);
  }

  @override
  Future<ISocketController> webSocket(String tailUrl) async {
    if (socketMap[tailUrl] == null)
      socketMap[tailUrl] = await handleWebSocket(
        tailUrl,
        () => socketMap.remove(tailUrl),
      );
    return socketMap[tailUrl];
  }
}

class SocketCtrlImpl extends ISocketController {
  final WebSocketChannel _channel;
  final Function _onClose;

  @override
  Stream stream;

  SocketCtrlImpl(this._channel, this._onClose)
      : stream = _channel.stream.asBroadcastStream()
          ..listen((event) => print('SocketCtrlImpl #Ws接收: [\n$event\n]'));

  @override
  void addRaw(String data) {
    if (!kReleaseMode) print('SocketCtrlImpl.add # Ws发送: [\n$data\n]');
    _channel.sink.add(data);
  }

  @override
  Future<void> close(
      {int closeCode: WsCloseCode.normalClosure, String closeReason}) {
    if (!kReleaseMode) print('WsCtrlImpl.close # ws断开连接');
    _channel.sink.close(closeCode, closeReason);
    _onClose();
    return null;
  }
}
