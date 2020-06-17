# get_arch_quick_start

GetArch quick start support

## Getting Started

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