# get_arch_quick_start

GetArch quick start support

## Getting Started

# 1. Init
请在主项目的 GetArchApplicationX.runMaterialApp() 中初始化本模块
```dart
Future<void> main() async {
  await GetArchApplicationX.flutterRunMaterialApp(
    EnvConfig(
              // ... 配置信息 ...
    ),
    packages: [
      QuickStartPackage(openStorageImpl: true, openDialogImpl: true),
      UserPackage(
        openIUserAPI: true,
        httpImplName: k_shuttle_http,
      ),
    ],
    title: 'App Name',
    theme: ThemeData(primarySwatch: Colors.blue),
  );
}
```
或者使用 GetArchApplication.run()
```dart
Future<void> main() async {
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

# 3. Use ISocket
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

# 5. Use IDialog
```dart
// ... 在某个 Widget的 build方法内 ...
builder(BuildContext context){
  final f = funcMayReturnFailure();
  if(f!=null){
    GetIt.I<IDialog>().err(f, tag: 'XxxBuider',ctx: context);
  }else{
    GetIt.I<IDialog>().toast('Success!');
  }
}
```
如果使用IDialog来处理抛出的Failure, 可以考虑结合FailureRoute实现更强大的功能

```dart
@module
abstract class FailureRoutesModule{
  @singleton
  FailureRoute get failureRoute => FailureRoute(<Type, FailureDialogBuilder>{
    NotLoginFailure : (ctx, failure) => QuickAlert(
      title: Text('提示'),
      content: Text('请登陆后继续'),
      onConfirm: (){
        // ... 可以在这里通过Navigator跳转到登录页
      }
    );
  }
```
