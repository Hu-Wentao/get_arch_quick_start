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
          httpConfig: INetConfig(
            scheme: 'http',
            authority: 'www.example.com:88',
          ),
          socketConfig: INetConfig(
            scheme: 'ws',
            authority: 'www.example.com:8888',
          ),
        ),
        // .. 其他模块 ..
      ]);
  // 运行主程序
  runApp(MyApp());
}

```

# 2. Use INetwork

## IHttp 的使用
```dart
// 通讯协议和baseUrl 需要在 INetConfig中配置
foo() async {
  final http = await GetIt.I<IHttp>();
  final r = await http.get('/xxxx');
  print('$r');
}
```

## ISocket 的使用
```dart
// 通讯协议和baseUrl 需要在 INetConfig中配置
foo() async {
  final skt = await GetIt.I<ISocket>().webSocket('/xxxx');
  skt.stream.listen((e)=>print('WebSocket接收: $e'));
  skt.addRaw('Hello WebSocket');
  skt.close();
}
```

# 3. Use IStorage
```dart
foo(){
  final box = GetIt.I<IStorage>();
}
```