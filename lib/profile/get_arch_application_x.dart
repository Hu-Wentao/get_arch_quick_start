// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/7/24
// Time  : 17:11

// @dart=2.9

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_arch_core/get_arch_core.dart';

extension GetArchApplicationX on GetArchApplication {
  static Map<String, Object> customInfo = {};

  ///
  /// Flutter App可以使用该方法初始化应用
  /// ```dart
  /// main(){
  ///   await GetArchApplication.runFlutter(...);
  /// }
  /// ```
  /// [masterEnvConfig] App运行的默认环境, [packages]中没有被指定[EnvConfig]的模块都将使用该环境
  /// [run] 即 "runApp();" 的参数
  /// [packages] App所使用的其他GetArch模块
  /// [mockDiAndOtherInitFunc] 供测试时手动注册mock依赖, 或者添加一些自定义初始化的代码
  ///   代码将会在 "GetArchCorePackage.init()"之后, package.init()之前被执行
  /// [printLog] 是否打印配置结果(建议使用默认配置)
  static Future<void> runFlutter(
    EnvConfig masterEnvConfig, {
    @required Widget run,
    List<IGetArchPackage> packages,
    Future<void> Function(GetIt g) mockDiAndOtherInitFunc,
    bool printLog: !kReleaseMode,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetArchApplication.run(
        masterEnvConfig ?? EnvConfig.sign(EnvSign.prod),
        printConfig: printLog,
        packages: packages,
        mockDI: mockDiAndOtherInitFunc);
    if (run != null) runApp(run);
  }

  ///
  /// 内部已经预置了 BotToast初始化代码
  static Future<void> runMaterialApp(
    EnvConfig masterEnvConfig, {
    FutureOr<void> Function() beforeRun,
    List<IGetArchPackage> packages,
    Future<void> Function(GetIt g) mockDiAndOtherInitFunc,
    bool printLog: !kReleaseMode,
    Key key,
    GlobalKey<NavigatorState> navigatorKey,
    Widget home,
    Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
    String initialRoute,
    RouteFactory onGenerateRoute,
    InitialRouteListFactory onGenerateInitialRoutes,
    RouteFactory onUnknownRoute,
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    TransitionBuilder builder,
    String title = '',
    GenerateAppTitle onGenerateTitle,
    Color color,
    ThemeData theme,
    ThemeData darkTheme,
    ThemeMode themeMode = ThemeMode.system,
    Locale locale,
    Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates,
    LocaleListResolutionCallback localeListResolutionCallback,
    LocaleResolutionCallback localeResolutionCallback,
    Iterable<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
    bool debugShowMaterialGrid = false,
    bool showPerformanceOverlay = false,
    bool checkerboardRasterCacheImages = false,
    bool checkerboardOffscreenLayers = false,
    bool showSemanticsDebugger = false,
    bool debugShowCheckedModeBanner = true,
    Map<LogicalKeySet, Intent> shortcuts,
    Map<Type, Action<Intent>> actions,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await beforeRun?.call();
    await GetArchApplication.run(
        masterEnvConfig ?? EnvConfig.sign(EnvSign.prod),
        printConfig: printLog,
        packages: packages,
        mockDI: mockDiAndOtherInitFunc);
    runApp(MaterialApp(
      key: key,
      navigatorKey: navigatorKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      debugShowMaterialGrid: debugShowMaterialGrid,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
    ));
  }
}
