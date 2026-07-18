import 'dart:async';

import 'package:core_kit/app_bar/ck_app_bar.dart';
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/utils/ck_permission_helper.dart';
import 'package:core_kit/utils/ck_screen_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

coreKitInstanceSingleton get coreKitInstance =>
    coreKitInstanceSingleton.instance;

typedef NavigationBack = void Function();

typedef CorkitInitBuilder =
    Widget Function(BuildContext context, Widget? child);

/// Configures the password visibility toggle icons shown in text fields.
///
/// Pass a custom instance via [CoreKitConfig.passwordObscureIcon].
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

/// Global configuration for list/grid loader widgets.
/// Allows customizing the default loading indicator and "no more data" widget
/// both globally (via CoreKitConfig) and per-instance.
class CkListLoaderConfig {
  /// Widget shown when loading more items (pagination footer).
  final Widget loaderWidget;

  /// Widget shown when all pages have been loaded.
  final Widget noMoreDataWidget;

  const CkListLoaderConfig({
    this.loaderWidget = const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    ),
    this.noMoreDataWidget = const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text('No more data', style: TextStyle(color: Colors.grey)),
      ),
    ),
  });

  CkListLoaderConfig copyWith({
    Widget? loaderWidget,
    Widget? noMoreDataWidget,
  }) {
    return CkListLoaderConfig(
      loaderWidget: loaderWidget ?? this.loaderWidget,
      noMoreDataWidget: noMoreDataWidget ?? this.noMoreDataWidget,
    );
  }
}

class coreKitInstanceSingleton {
  coreKitInstanceSingleton._();
  static final coreKitInstanceSingleton _instance = coreKitInstanceSingleton
      ._();
  static coreKitInstanceSingleton get instance => _instance;

  late GlobalKey<NavigatorState> navigatorKey;
  late String imageBaseUrl;
  late Size designSize;
  late CkAppBarConfig appbarConfig;
  CkListLoaderConfig listLoaderConfig = const CkListLoaderConfig();
  late CkTransportConfig ckTransportConfig;

  CkPermissionHelperConfig permissionHelperConfig =
      const CkPermissionHelperConfig();
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

/// Colours used by the permission request UI overlay.
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

/// Abstract configuration class that every app must extend to initialise CoreKit.
///
/// Override the required getters ([imageBaseUrl], [ckTransportConfig], [designSize])
/// and optionally override [authConfig], [appbarConfig], [onInit] and others.
///
/// Example:
/// ```dart
/// class AppConfig extends CoreKitConfig with CoreKitConfigDefaults {
///   @override
///   String get imageBaseUrl => 'https://cdn.example.com/';
///   @override
///   CkTransportConfig get ckTransportConfig => CkTransportConfig(
///     baseUrl: 'https://api.example.com',
///     refreshTokenEndpoint: '/auth/refresh',
///   );
/// }
/// ```
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
      'Do NOT use `context` in imageBaseUrl, ckTransportConfig, or designSize.\n',
    );
    return _context!;
  }

  // ignore: invalid_internal_annotation
  @internal
  void attachContext(BuildContext ctx) => _context = ctx;

  String get imageBaseUrl;
  CkTransportConfig get ckTransportConfig;
  Size get designSize;

  CkAuthConfig? get authConfig => null;
  CkAppBarConfig? get appbarConfig => null;
  CkListLoaderConfig? get listLoaderConfig => null;
  CkPermissionHelperConfig? get permissionHelperConfig => null;
  PermissionHadlerColors? get permissionHandlerColors => null;
  PasswordObscureIcon? get passwordObscureIcon => null;

  /// New: UI shown before CoreKit is ready
  Widget? get preInitChild => null;

  /// Custom asynchronous initialization tasks run during the splash delay.
  Future<void> Function()? get onInit => null;

  /// Splash delay in milliseconds (default: 3000ms = 3 seconds)
  /// Set to 0 to disable the enforced delay
  int get splashDelayMs => 3000;
}

mixin CoreKitConfigDefaults on CoreKitConfig {
  @override
  CkAuthConfig? get authConfig => null;
  @override
  CkAppBarConfig? get appbarConfig => null;
  @override
  CkListLoaderConfig? get listLoaderConfig => null;
  @override
  CkPermissionHelperConfig? get permissionHelperConfig => null;
  @override
  PermissionHadlerColors? get permissionHandlerColors => null;
  @override
  PasswordObscureIcon? get passwordObscureIcon => null;
  @override
  Size get designSize => const Size(428, 926);
  @override
  Widget? get preInitChild => null;
  @override
  Future<void> Function()? get onInit => null;
  @override
  int get splashDelayMs => 3000;
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
  bool _initStarted = false;
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guard: only run once — didChangeDependencies fires on every dependency
    // change (theme, locale, MediaQuery, etc.) but init must run exactly once.
    if (_initStarted) return;
    _initStarted = true;
    _initializeCoreKit();
  }

  Future<void> _initializeCoreKit() async {
    final completer = Completer<void>();
    final stopwatch = Stopwatch()..start();

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

      instance.appbarConfig = config.appbarConfig ?? CkAppBarConfig();
      if (instance.appbarConfig.onBack == null) {
        instance.appbarConfig = instance.appbarConfig.copyWith(
          onBack: () => instance.navigatorKey.currentState?.pop(),
        );
      }
      if (config.listLoaderConfig != null) {
        instance.listLoaderConfig = config.listLoaderConfig!;
      }

      // ── First-install wipe ────────────────────────────────────────────
      // On a fresh install, clear any stale secure-storage data left over
      // from a previous installation. CkStorage.deleteAll() already
      // preserves keys registered via protectKey (e.g. the device id).
      // We use SharedPreferences for the flag itself because CkStorage
      // (secure storage) is the thing being wiped.
      await CkStorage.initialize();
      final prefs = await SharedPreferences.getInstance();
      final hasBeenInstalled = prefs.getBool('ck_app_installed') ?? false;
      if (!hasBeenInstalled) {
        await CkStorage.deleteAll();
        await prefs.setBool('ck_app_installed', true);
      }

      if (config.authConfig != null) {
        final authNetwork = await CkAuthService.prepareNetwork(
          config: config.authConfig!,
        );
        await CkTransport.init(
          config: config.ckTransportConfig,
          tokenProvider: authNetwork.tokenProvider,
        );
        await CkAuthService.init(
          config: config.authConfig!,
          tokenManager: authNetwork.tokenManager,
        );
      } else {
        await CkTransport.init(
          config: config.ckTransportConfig,
          tokenProvider: CkTokenProvider.unauthenticated(),
        );
      }

      // Execute developer's custom initialization tasks during the splash delay
      if (config.onInit != null) {
        try {
          await config.onInit!();
        } catch (_) {}
      }

      // Enforce configured splash delay (default: 3000ms)
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final delayMs = config.splashDelayMs;
      final remainingMs = delayMs - elapsedMs;
      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }
      stopwatch.stop();

      // Trigger automatic navigation immediately after delay finishes
      if (config.authConfig != null && CkAuthService.isInitialized) {
        CkAuthService.instance.autoNavigate();
      }

      CkScreenUtils.init(context, () => completer.complete());
    });

    await completer.future;

    if (mounted) {
      setState(() => _initDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      if (widget.config.preInitChild != null) {
        return Scaffold(body: widget.config.preInitChild!);
      }
      return widget.child;
    }
    return widget.child;
  }
} // CoreKit — main widget
// ============================================================

/// The root widget for a CoreKit-powered Flutter app (standard navigator).
///
/// Drop-in replacement for [MaterialApp] that additionally bootstraps
/// [CkTransport], [CkStorage], [CkAuthService] and responsive-screen scaling.
///
/// Use [CoreKit.router] when using a declarative routing package (go_router, etc.).
/// Use [CoreKit.builder] when wrapping an existing [MaterialApp.router].
///
/// Example:
/// ```dart
/// void main() => runApp(MyApp());
///
/// class MyApp extends StatelessWidget {
///   final _nav = GlobalKey<NavigatorState>();
///   @override
///   Widget build(BuildContext context) => CoreKit(
///     navigatorKey: _nav,
///     config: AppConfig(),
///     home: const HomeScreen(),
///   );
/// }
/// ```
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
    instance.ckTransportConfig = config.ckTransportConfig;
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
