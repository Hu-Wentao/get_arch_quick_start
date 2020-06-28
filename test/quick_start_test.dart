// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/6/18
// Time  : 10:38
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_arch_core/domain/env_config.dart';
import 'package:get_arch_core/get_arch_core.dart';
import 'package:get_arch_quick_start/profile/get_arch_package.dart';
import 'package:get_arch_quick_start/infrastructure/network_impl.dart';
import 'package:get_it/get_it.dart';

main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetArchApplication.run(
        EnvConfig(
          'QuickStart测试',
          '0.0.1',
          DateTime(2020, 6, 18),
          EnvSign.prod,
        ),
        packages: [
          QuickStartPackage(
            httpConfig: HttpConfig('http', 'wap.baidu.com', null),
            socketConfig: SocketConfig('ws', '', null),
          )
        ]);
  });
  test('http', () async {
    // 这里注册的类型为 IHttp,因此获取时如果使用<HttpImpl>将会报错
    final h = GetIt.I<IHttp>();
    final wd = 'aaaa';
    final r = await h.get('/s', queryParameters: {
      "wd": "$wd",
      "ie": "UTF-8",
    });

    print(r);
  });
  test('socket', () {});
  test('storage', () {});
}
