import 'dart:async';

import 'package:core_kit/app_bar/common_app_bar.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/network/dio_service_config.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:core_kit/utils/permission_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

coreKitInstanceSingleton get coreKitInstance =>
    coreKitInstanceSingleton.instance;

typedef NavigationBack = void Function();

typedef CorkitInitBuilder =
    Widget Function(BuildContext context, Widget? child);

class PasswordObscureIcon {
  final Widget show;
  final Widget hide;
  final EdgeInsetsGeometry padding;
  PasswordObscureIcon({
    required this.show,
    required this.hide,
    this.padding = const EdgeInsetsDirectional.only(end: 10),
  });
}

class coreKitInstanceSingleton {
  coreKitInstanceSingleton._();
  static final coreKitInstanceSingleton _instance = coreKitInstanceSingleton
      ._();
  static coreKitInstanceSingleton get instance => _instance;

  late GlobalKey<NavigatorState> navigatorKey;
  late String imageBaseUrl;
  late Size designSize;
  late AppbarConfig appbarConfig;
  late DioServiceConfig dioServiceConfig;
  late TokenProvider tokenProvider;

  PermissionHelperConfig permissionHelperConfig =
      const PermissionHelperConfig();
  PasswordObscureIcon passWordObscureIcon = PasswordObscureIcon(
    padding: const EdgeInsetsDirectional.only(end: 10),
    show: const Icon(Icons.visibility, size: 20),
    hide: const Icon(Icons.visibility_off, size: 20),
  );
  PermissionHadlerColors permissionHandlerColors = PermissionHadlerColors(
    errorColor: Colors.red,
    actionColor: Colors.green,
    normalColor: Colors.black,
  );

  ThemeData get theme => Theme.of(navigatorKey.currentContext!);
  String? get fontFamily => theme.textTheme.bodyMedium?.fontFamily;
  TextStyle? get defaultTextStyle => theme.textTheme.bodyMedium;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get primaryColor => theme.primaryColor;
  Color get onPrimaryColor => theme.colorScheme.onPrimary;
  Color get secondaryColor => theme.colorScheme.secondary;
  Color get outlineColor => theme.colorScheme.outline;
  Color get surfaceBG => theme.colorScheme.surface;
}

class PermissionHadlerColors {
  final Color errorColor;
  final Color actionColor;
  final Color normalColor;

  PermissionHadlerColors({
    required this.errorColor,
    required this.actionColor,
    required this.normalColor,
  });
}

// ============================================================
// CoreKitConfig — abstract config with context injection
// ============================================================

abstract class CoreKitConfig {
  BuildContext? _context;
  @protected
  BuildContext get context {
    assert(
      _context != null,
      '\n\ncoreKitInstance context is not available yet.\n'
      'Only use `context` inside these getters:\n'
      '  - appbarConfig\n'
      '  - permissionHandlerColors\n'
      '  - passwordObscureIcon\n'
      '  - permissionHelperConfig\n'
      'Do NOT use `context` in imageBaseUrl, dioConfig, tokenProvider, or designSize.\n',
    );
    return _context!;
  }

  // ignore: invalid_internal_annotation
  @internal
  void attachContext(BuildContext ctx) => _context = ctx;

  String get imageBaseUrl;
  DioServiceConfig get dioConfig;
  TokenProvider get tokenProvider;
  Size get designSize;

  AppbarConfig? get appbarConfig => null;
  PermissionHelperConfig? get permissionHelperConfig => null;
  PermissionHadlerColors? get permissionHandlerColors => null;
  PasswordObscureIcon? get passwordObscureIcon => null;

  /// New: UI shown before CoreKit is ready
  Widget? get preInitChild => null;
}

mixin CoreKitConfigDefaults implements CoreKitConfig {
  @override
  AppbarConfig? get appbarConfig => null;
  @override
  PermissionHelperConfig? get permissionHelperConfig => null;
  @override
  PermissionHadlerColors? get permissionHandlerColors => null;
  @override
  PasswordObscureIcon? get passwordObscureIcon => null;
  @override
  Size get designSize => const Size(428, 926);
  @override
  Widget? get preInitChild => Container();
}

// ============================================================
// CoreKitRouterGate — blocks splash until CoreKit initialized
// ============================================================

class CoreKitRouterGate extends StatefulWidget {
  final CoreKitConfig config;
  final Widget child;

  const CoreKitRouterGate({
    required this.config,
    required this.child,
    super.key,
  });

  @override
  State<CoreKitRouterGate> createState() => _CoreKitRouterGateState();
}

class _CoreKitRouterGateState extends State<CoreKitRouterGate> {
  bool _dioInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCoreKit();
  }

  Future<void> _initializeCoreKit() async {
    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final instance = coreKitInstance;
      final config = widget.config;

      config.attachContext(context);

      if (config.permissionHelperConfig != null) {
        instance.permissionHelperConfig = config.permissionHelperConfig!;
      }
      if (config.permissionHandlerColors != null) {
        instance.permissionHandlerColors = config.permissionHandlerColors!;
      }
      if (config.passwordObscureIcon != null) {
        instance.passWordObscureIcon = config.passwordObscureIcon!;
      }

      instance.appbarConfig = config.appbarConfig ?? AppbarConfig();
      if (instance.appbarConfig.onBack == null) {
        instance.appbarConfig = instance.appbarConfig.copyWith(
          onBack: () => instance.navigatorKey.currentState?.pop(),
        );
      }
      if (!_dioInitialized) {
        _dioInitialized = true;
        await DioService.init(
          config: config.dioConfig,
          tokenProvider: config.tokenProvider,
        );
      }
      CoreScreenUtils.init(context, () => completer.complete());
    });

    await completer.future;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_dioInitialized) {
      return Scaffold(body: widget.config.preInitChild ?? Container());
    }
    return widget.child;
  }
} // CoreKit — main widget
// ============================================================

class CoreKit extends StatefulWidget {
  final CoreKitConfig config;
  final GlobalKey<NavigatorState> navigatorKey;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final String title;
  final String? restorationScopeId;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardOffscreenLayers;
  final bool checkerboardRasterCacheImages;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final bool debugShowMaterialGrid;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver> navigatorObservers;
  final RouterConfig<Object>? routerConfig;
  final bool ensureScreenSize;
  final ScrollBehavior? scrollBehavior;
  final Duration themeAnimationDuration;
  final Curve themeAnimationCurve;
  final Widget Function(CorkitInitBuilder builder)? app;

  const CoreKit({
    super.key,
    required this.config,
    required this.navigatorKey,
    this.ensureScreenSize = true,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.title = '',
    this.restorationScopeId,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardOffscreenLayers = false,
    this.checkerboardRasterCacheImages = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.themeAnimationDuration = const Duration(milliseconds: 300),
    this.themeAnimationCurve = Curves.easeInOut,
    this.shortcuts,
    this.actions,
    this.debugShowMaterialGrid = false,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.scrollBehavior,
  }) : routerConfig = null,
       app = null;

  const CoreKit.builder({
    super.key,
    required this.config,
    required this.navigatorKey,
    required this.app,
    this.ensureScreenSize = true,
  }) : routerConfig = null,
       theme = null,
       darkTheme = null,
       themeMode = null,
       title = '',
       restorationScopeId = null,
       locale = null,
       localizationsDelegates = null,
       localeListResolutionCallback = null,
       localeResolutionCallback = null,
       supportedLocales = const <Locale>[Locale('en', 'US')],
       showPerformanceOverlay = false,
       checkerboardOffscreenLayers = false,
       checkerboardRasterCacheImages = false,
       showSemanticsDebugger = false,
       debugShowCheckedModeBanner = true,
       themeAnimationDuration = const Duration(milliseconds: 300),
       themeAnimationCurve = Curves.easeInOut,
       shortcuts = null,
       actions = null,
       debugShowMaterialGrid = false,
       home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onUnknownRoute = null,
       navigatorObservers = const <NavigatorObserver>[],
       scrollBehavior = null;

  const CoreKit.router({
    super.key,
    required this.config,
    required this.routerConfig,
    required this.navigatorKey,
    this.ensureScreenSize = true,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.title = '',
    this.restorationScopeId,
    this.scrollBehavior,
    this.locale,
    this.themeAnimationDuration = const Duration(milliseconds: 300),
    this.themeAnimationCurve = Curves.easeInOut,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardOffscreenLayers = false,
    this.checkerboardRasterCacheImages = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.debugShowMaterialGrid = false,
  }) : home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onUnknownRoute = null,
       app = null,
       navigatorObservers = const <NavigatorObserver>[];

  @override
  State<CoreKit> createState() => _CoreKitState();
}

class _CoreKitState extends State<CoreKit> {
  @override
  void initState() {
    super.initState();
    final instance = coreKitInstance;
    final config = widget.config;

    instance.navigatorKey = widget.navigatorKey;
    instance.imageBaseUrl = config.imageBaseUrl;
    instance.designSize = config.designSize;
    instance.dioServiceConfig = config.dioConfig;
    instance.tokenProvider = config.tokenProvider;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.app != null) {
      return widget.app!.call(_buildRouteGate);
    }
    if (widget.routerConfig != null) {
      return MaterialApp.router(
        key: widget.key,
        routerConfig: widget.routerConfig,
        scrollBehavior: widget.scrollBehavior,
        themeAnimationDuration: widget.themeAnimationDuration,
        themeAnimationCurve: widget.themeAnimationCurve,
        theme: widget.theme,
        darkTheme: widget.darkTheme,
        themeMode: widget.themeMode,
        title: widget.title,
        restorationScopeId: widget.restorationScopeId,
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales: widget.supportedLocales,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
        checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
        debugShowMaterialGrid: widget.debugShowMaterialGrid,
        builder: (context, child) => _buildRouteGate(context, child),
      );
    }

    return MaterialApp(
      key: widget.key,
      navigatorKey: widget.navigatorKey,
      scrollBehavior: widget.scrollBehavior,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      themeMode: widget.themeMode,
      themeAnimationDuration: widget.themeAnimationDuration,
      themeAnimationCurve: widget.themeAnimationCurve,
      title: widget.title,
      restorationScopeId: widget.restorationScopeId,
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
      debugShowMaterialGrid: widget.debugShowMaterialGrid,
      home: widget.home,
      routes: widget.routes,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers: widget.navigatorObservers,
      builder: (context, child) => _buildRouteGate(context, child),
    );
  }

  Widget _buildRouteGate(BuildContext context, Widget? child) =>
      CoreKitRouterGate(
        config: widget.config,
        child: child ?? const SizedBox.shrink(),
      );
}
