# get_arch_quick_start

GetArch quick start support

## Getting Started

# 1. Init
请在主项目的 GetArchApplication.run() 中初始化本模块
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetArchApplication.run(
      EnvConfig(
          // ... 配置信息 ...
          ),
      packages: [
        // 配置 QuickStartPackage
        QuickStartPackage(
          httpConfig: HttpConfig(
            'http',
            'www.example.com:88',
            null,
          ),
          socketConfig: INetConfig(  
            'ws',
            'www.example.com:8888',
            null,
          ),
        ),
        // .. 其他模块 ..
      ]);
  // 运行主程序
  runApp(MyApp());
}

```

# 2. Use IHttp
```dart
// 通讯协议和baseUrl 需要在 INetConfig中配置
foo() async {
  final http = await GetIt.I<IHttp>();
  final r = await http.get('/xxxx');
  print('$r');
}
```

## 3. Use ISocket
```dart
// 通讯协议和baseUrl 需要在 INetConfig中配置
foo() async {
  final skt = await GetIt.I<ISocket>().webSocket('/xxxx');
  skt.stream.listen((e)=>print('WebSocket接收: $e'));
  skt.addRaw('Hello WebSocket');
  skt.close();
}
```

# 4. Use IStorage
```dart
foo(){
  final box = GetIt.I<IStorage>();
}
```