/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:18:19
 * @Email: km.muzahid@gmail.com
 */

import 'package:core_kit/app_bar/common_app_bar.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:core_kit/utils/permission_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Library-private accessor for internal use within the core_kit package.
/// Not exported from public API - external users should not use this.
coreKitInstanceSingleton get coreKitInstance =>
    coreKitInstanceSingleton.instance;

typedef NavigationBack = void Function();

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

  static final coreKitInstanceSingleton _instance = coreKitInstanceSingleton._();
  static coreKitInstanceSingleton get instance => _instance;

  late GlobalKey<NavigatorState> navigatorKey;
  late String imageBaseUrl;
  late Size designSize;
  late AppbarConfig appbarConfig;
  late DioServiceConfig dioServiceConfig;
  late TokenProvider tokenProvider;

  PermissionHelperConfig permissionHelperConfig = PermissionHelperConfig();
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

  @Deprecated('Use CoreKit or CoreKit.router instead')
  static Widget init({
    required String imageBaseUrl,
    required GlobalKey<NavigatorState> navigatorKey,
    required DioServiceConfig dioServiceConfig,
    required TokenProvider tokenProvider,
    PasswordObscureIcon? passwordObscureIcon,
    AppbarConfig? appbarConfig,
    PermissionHadlerColors? permissionHandlerColors,
    Widget? child,
    Size designSize = const Size(428, 926),
    PermissionHelperConfig? permissionHelperStrings,
  }) {
    return _LegacyInitWrapper(
      designSize: designSize,
      permissionHelperStrings: permissionHelperStrings,
      permissionHandlerColors: permissionHandlerColors,
      appbarConfig: appbarConfig,
      navigatorKey: navigatorKey,
      imageBaseUrl: imageBaseUrl,
      dioServiceConfig: dioServiceConfig,
      tokenProvider: tokenProvider,
      passwordObscureIcon: passwordObscureIcon,
      child: child,
    );
  }
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
// Legacy wrapper — kept intact, do not modify
// ============================================================

class _LegacyInitWrapper extends StatefulWidget {
  const _LegacyInitWrapper({
    required this.child,
    required this.dioServiceConfig,
    required this.tokenProvider,
    required this.designSize,
    required this.permissionHelperStrings,
    required this.permissionHandlerColors,
    required this.appbarConfig,
    this.passwordObscureIcon,
    required this.navigatorKey,
    required this.imageBaseUrl,
  });
  final Widget? child;
  final DioServiceConfig dioServiceConfig;
  final TokenProvider tokenProvider;
  final PasswordObscureIcon? passwordObscureIcon;
  final Size designSize;
  final PermissionHelperConfig? permissionHelperStrings;
  final PermissionHadlerColors? permissionHandlerColors;
  final AppbarConfig? appbarConfig;
  final GlobalKey<NavigatorState> navigatorKey;
  final String imageBaseUrl;

  @override
  State<_LegacyInitWrapper> createState() => _LegacyInitWrapperState();
}

@Deprecated('Use CoreKit or CoreKit.router instead')
class _LegacyInitWrapperState extends State<_LegacyInitWrapper> {
  final coreKitInstanceSingleton _instance = coreKitInstanceSingleton.instance;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    CoreScreenUtils.init(context, () {});
  }

  @override
  void initState() {
    super.initState();
    _instance.designSize = widget.designSize;
    if (widget.permissionHelperStrings != null) {
      _instance.permissionHelperConfig = widget.permissionHelperStrings!;
    }
    _instance.navigatorKey = widget.navigatorKey;
    _instance.imageBaseUrl = widget.imageBaseUrl;
    if (widget.permissionHandlerColors != null) {
      _instance.permissionHandlerColors = widget.permissionHandlerColors!;
    }
    if (widget.passwordObscureIcon != null) {
      _instance.passWordObscureIcon = widget.passwordObscureIcon!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoreScreenUtils.init(context, () {
        _instance.appbarConfig = widget.appbarConfig ?? AppbarConfig();
        if (_instance.appbarConfig.onBack == null) {
          _instance.appbarConfig = _instance.appbarConfig.copyWith(
            onBack: () => Navigator.pop(context),
          );
        }
        DioService.init(
          config: widget.dioServiceConfig,
          tokenProvider: widget.tokenProvider,
        );
        setState(() => isInitialized = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isInitialized
        ? widget.child ?? Container()
        : Scaffold(body: widget.child ?? Container());
  }
}

// ============================================================
// CoreKitConfig — abstract config with context injection
// ============================================================

/// Abstract class that defines required configuration for CoreKit.
///
/// Implement this class to provide all required configurations for CoreKit.
/// Use [CoreKitConfigDefaults] mixin to get default values for optional properties.
///
/// Context-aware getters (appbarConfig, permissionHandlerColors, etc.)
/// can safely use [context] — it is injected by CoreKit before any
/// getter is called.
///
/// Example:
/// ```dart
/// class MyConfig extends CoreKitConfig with CoreKitConfigDefaults {
///   @override
///   String get imageBaseUrl => 'https://api.example.com/images/';
///
///   @override
///   DioServiceConfig get dioConfig => DioServiceConfig(...);
///
///   @override
///   TokenProvider get tokenProvider => TokenProvider(...);
///
///   @override
///   AppbarConfig? get appbarConfig => AppbarConfig(
///     backgroundColor: context.colors.surface,
///     titleStyle: TextStyle(color: context.colors.onSurface),
///   );
///
///   @override
///   PermissionHadlerColors? get permissionHandlerColors =>
///     PermissionHadlerColors(
///       errorColor: context.colors.error,
///       actionColor: context.colors.primary,
///       normalColor: context.colors.onSurface,
///     );
/// }
/// ```
abstract class CoreKitConfig {
  BuildContext? _context;

  /// The BuildContext injected by CoreKit after MaterialApp is built.
  ///
  /// Safe to use inside any getter — CoreKit guarantees this is set
  /// before appbarConfig, permissionHandlerColors, passwordObscureIcon,
  /// and permissionHelperConfig are ever read.
  ///
  /// Do NOT use this inside imageBaseUrl, dioConfig, tokenProvider,
  /// or designSize — those are read before context is available.
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

  /// Called internally by CoreKit once a valid BuildContext is available.
  /// Do not call this manually.
  @internal
  void attachContext(BuildContext ctx) => _context = ctx;

  // ── Pure values — context not available, do not use context here ──

  /// Base URL for images.
  /// Used by CommonImage to build full image URLs from relative paths.
  String get imageBaseUrl;

  /// Dio service configuration for network requests.
  DioServiceConfig get dioConfig;

  /// Token provider for authentication handling.
  TokenProvider get tokenProvider;

  /// Design size for responsive scaling.
  /// Default: Size(428, 926) - iPhone 14 Pro Max dimensions
  Size get designSize;

  // ── Context-aware — context is safe to use in these getters ──

  /// Optional app bar configuration.
  /// context is available here — use context.colors, context.theme, etc.
  AppbarConfig? get appbarConfig => null;

  /// Optional permission helper strings for localization.
  /// context is available here.
  PermissionHelperConfig? get permissionHelperConfig => null;

  /// Optional permission handler colors for theming.
  /// context is available here — use context.colors, context.theme, etc.
  PermissionHadlerColors? get permissionHandlerColors => null;

  /// Optional password obscure icon configuration.
  /// context is available here — use context.colors, context.theme, etc.
  PasswordObscureIcon? get passwordObscureIcon => null;
}

/// Mixin to provide default values for optional [CoreKitConfig] properties.
///
/// Example:
/// ```dart
/// class MyConfig extends CoreKitConfig with CoreKitConfigDefaults {
///   // Only implement required properties
/// }
/// ```
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
}

// ============================================================
// _CoreKitInitWrapper
//
// Lives inside MaterialApp builder: — context is always valid here.
// Injects context into config, then reads all context-aware getters.
// Holds child hostage until ready, then releases — identical to legacy.
// ============================================================

class _CoreKitInitWrapper extends StatefulWidget {
  const _CoreKitInitWrapper({required this.config, required this.child});

  final CoreKitConfig config;
  final Widget? child;

  @override
  State<_CoreKitInitWrapper> createState() => _CoreKitInitWrapperState();
}

class _CoreKitInitWrapperState extends State<_CoreKitInitWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm up CoreScreenUtils on dependency changes — same as legacy
    CoreScreenUtils.init(context, () {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoreScreenUtils.init(context, () {
        final instance = coreKitInstance;
        final config = widget.config;

        // ✅ Inject context first — all context-aware getters are now safe
        config.attachContext(context);

        // Now read context-aware getters safely
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

        DioService.init(config: config.dioConfig, tokenProvider: config.tokenProvider);

        // Release child — identical to legacy setState pattern
        setState(() => _initialized = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Identical to legacy _SetChild:
    // child always stays in the tree (theme extensions available)
    // but navigation is blocked until _initialized
    return _initialized
        ? widget.child ?? const SizedBox.shrink()
        : Scaffold(body: widget.child ?? const SizedBox.shrink());
  }
}

// ============================================================
// CoreKit — main widget
// ============================================================

/// CoreKit - Main application wrapper widget.
///
/// Handles initialization of all CoreKit services including:
/// - Dio service for network requests
/// - Responsive screen utilities
/// - App bar configuration
/// - Permission handling
/// - Theme and navigation
///
/// Example using standard routing:
/// ```dart
/// CoreKit(
///   config: MyAppConfig(),
///   navigatorKey: myNavigatorKey,
///   home: HomeScreen(),
///   theme: ThemeData(...),
/// )
/// ```
///
/// Example using go_router:
/// ```dart
/// CoreKit.router(
///   config: MyAppConfig(),
///   navigatorKey: goRouter.routerDelegate.navigatorKey,
///   routerConfig: goRouter,
///   theme: ThemeData(...),
/// )
/// ```
class CoreKit extends StatefulWidget {
  /// Required configuration implementing [CoreKitConfig].
  final CoreKitConfig config;

  /// Navigator key — must be the same key used by your router.
  /// For GoRouter: pass `goRouter.routerDelegate.navigatorKey`
  /// For standard routing: create a GlobalKey and pass it here.
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
  }) : routerConfig = null;

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
       navigatorObservers = const <NavigatorObserver>[];

  @override
  State<CoreKit> createState() => _CoreKitState();
}

class _CoreKitState extends State<CoreKit> {
  @override
  void initState() {
    super.initState();
    // Assign all context-free config immediately — safe in initState.
    // Context-dependent config (appbarConfig, permissionHandlerColors,
    // passwordObscureIcon, permissionHelperConfig) is handled inside
    // _CoreKitInitWrapper after context is injected via attachContext.
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
    if (widget.routerConfig != null) {
      return MaterialApp.router(
        key: widget.key,
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
        routerConfig: widget.routerConfig,
        builder: (context, child) => _CoreKitInitWrapper(config: widget.config, child: child),
      );
    }

    return MaterialApp(
      key: widget.key,
      scrollBehavior: widget.scrollBehavior,
      navigatorKey: widget.navigatorKey,
      theme: widget.theme,
      themeAnimationDuration: widget.themeAnimationDuration,
      themeAnimationCurve: widget.themeAnimationCurve,
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
      home: widget.home,
      routes: widget.routes,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers: widget.navigatorObservers,
      builder: (context, child) => _CoreKitInitWrapper(config: widget.config, child: child),
    );
  }
}
