## [1.0.0] -2020/8/2
* add(get_arch_application_x.dart):
 新增扩展方法flutterRun();
 新增扩展方法flutterRunMaterialApp();
 已兼容>3.0.0的BotToast;
* refactor(failures.dart,dialog_impl.dart): 适配v1.0.0版本GetArchCore的UnknownFailure
* feat(IHttp):
 新增handleBytesRequest(),直接返回byte信息(用于获取图片bytes);
 handleRequest()新增dynamic data参数;
* feat(network_impl): 适配新的接口;
* refactor(dialog_impl/QuickDialog):
  新增 FailureRoute,IDialog收到异常后,可以展示对应的DIalog;
  新增 QuickAlter,快速构建美观的Dialog;
  新增IDialog接口多个方法, 本类添加多个实现 selectTips(), err(), toast(), snack(), widget();
* refactor(quick_start_package):
  适配1.0.0以上的Injectable;

## [0.6.3] -2020/7/5
* IStorage新增 Uint8List类型, int类型数据的读写, StorageImpl添加对应实现

## [0.6.2] -2020/7/4
* 升级GetArchCore到v0.6.1

## [0.6.1] -2020/7/4
* 导出i_get_arch_package，web_socket_channel

## [0.6.0] -2020/7/3
* 从 GetArchCore接收大量通用类与基础设施接口

## [0.4.1] -2020/7/1
* 修复 HttpImpl只能发送get请求的bug

## [0.4.0] -2020/6/30
* 适配 get_arch_core v0.4.0 的配置输出方法,
Map<String, bool> get printBoolStateWithRegTypeName;  
Map<String, String> printOtherStateWithEnvConfig(EnvConfig config);

## [0.2.1] - 2020/6/24
* 适配 get_arch_core v0.2.1
* 使用 flutter format格式化代码

## [0.2.0] - 2020/6/20
* 基于 get_arch_core v0.2.0
* refactor(QuickDialogHelper): 去除auto_route耦合
* add(HttpConfig,SocketConfig): 继承自INetConfig
* refactor(HttpImpl): 去除注解,实例名,手动注册为 IHttp
* refactor(SocketImpl): 去除注解,实例名,手动注册为 ISocket
* refactor(StorageImpl): 去除注解,实例名,手动注册为 IStorage
* feat(QuickStartPackage): printPackageConfigInfo,打印包配置信息
* feat(QuickStartPackage): 允许控制IDialogHelper启用状态
* add(quick_start_test.dart): 测试信息打印效果
* refactor(SocketCtrlImpl): 适配get_arch_core的更新;
* rename(ProfileQuickStart): 不同的模块在导入的时候会导致ProfileModule类重名
* refactor: 修改HttpImpl与SocketImpl的注册类型为IHttp与ISocket
* refactor: SocketCtrlImpl数据写入方法变更

## [0.0.2] - 2020/6/17

* 修复 QuickStartPackage没有继承 IGatArchPackage的问题

## [0.0.1] - 2020/6/17

* 首次提交
