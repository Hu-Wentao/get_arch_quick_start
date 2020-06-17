// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/4/13
// Time  : 15:09

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_arch_core/get_arch_part.dart';
import 'package:get_arch_core/interface/i_common_interface.dart';
import 'package:get_arch_core/interface/i_network.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const k_http_config = 'k_http_config';
const k_socket_config = 'k_socket_config';

@LazySingleton(as: IHttp)
class HttpImpl extends IHttp {
  final Dio _dio;
  @override
  INetConfig config;

  HttpImpl(@Named(k_http_config) this.config)
      : _dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
//            headers: {}..addAll(config.staticHeaders),
          ),
        )..interceptors.addAll([
            PrettyDioLogger(request: false, requestBody: true),
          ]);

  @override
  Future handleRequest(String type, String tailUrl,
          {IDto dto, Map<String, dynamic> queryParameters}) =>
      _dio.request(tailUrl,
          data: dto?.toJson(), queryParameters: queryParameters);
}

@LazySingleton(as: ISocket)
class SocketImpl extends ISocket {
  @override
  final INetConfig config;
  Map<String, ISocketController> socketMap = <String, ISocketController>{};

  SocketImpl(@Named(k_socket_config) this.config);

  Future<ISocketController> handleWebSocket(
      String tailUrl, void Function() onClose) async {
    final uri = Uri.parse(config.baseUrl + tailUrl);
    final channel = WebSocketChannel.connect(uri);
    return SocketCtrlImpl<Map<String, dynamic>>(channel, onClose);
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

class SocketCtrlImpl<T> extends ISocketController<T> {
  final WebSocketChannel _channel;
  final Function _onClose;

  @override
  Stream<T> stream;

  SocketCtrlImpl(this._channel, this._onClose)
      : stream = _channel.stream.map<T>((d) {
          if (!kReleaseMode) print('WsCtrlImpl.stream: # Ws接收: [\n$d\n]');
          return jsonDecode(d);
        }).asBroadcastStream();

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
