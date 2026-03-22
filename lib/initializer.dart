/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:18:19
 * @Email: km.muzahid@gmail.com
 */

import 'package:core_kit/app_bar/common_app_bar.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:core_kit/utils/permission_helper.dart';
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

  static final coreKitInstanceSingleton _instance = coreKitInstanceSingleton
      ._();
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

class _LegacyInitWrapper extends StatefulWidget {
  const _LegacyInitWrapper({
    super.key,
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

/// Abstract class that defines required configuration for CoreKit.
///
/// Implement this class to provide all required configurations for CoreKit.
/// Use [CoreKitConfigDefaults] mixin to get default values for optional properties.
///
/// Example:
/// ```dart
/// class MyConfig extends CoreKitConfig with CoreKitConfigDefaults {
///   @override
///   String get imageBaseUrl => 'https://api.example.com/images/';
///
///   @override
///   DioServiceConfig get dioConfig => DioServiceConfig(
///     baseUrl: 'https://api.example.com',
///     refreshTokenEndpoint: '/auth/refresh',
///   );
///
///   @override
///   TokenProvider get tokenProvider => TokenProvider(...);
/// }
/// ```
abstract class CoreKitConfig {
  /// Base URL for images.
  ///
  /// Used by [CommonImage] to build full image URLs from relative paths.
  /// Should end with a trailing slash.
  String get imageBaseUrl;

  /// Dio service configuration for network requests.
  ///
  /// Defines base URL, timeouts, and token refresh endpoint.
  DioServiceConfig get dioConfig;

  /// Token provider for authentication handling.
  ///
  /// Provides access token, refresh token, and token update logic.
  TokenProvider get tokenProvider;

  /// Optional app bar configuration.
  ///
  /// Default: null (uses [AppbarConfig] defaults)
  AppbarConfig? get appbarConfig;

  /// Optional permission helper strings for localization.
  ///
  /// Default: null (uses English defaults)
  PermissionHelperConfig? get permissionHelperConfig;

  /// Optional permission handler colors for theming.
  ///
  /// Default: null (uses red/green/black defaults)
  PermissionHadlerColors? get permissionHandlerColors;

  /// Optional password obscure icon configuration.
  ///
  /// Default: null (uses standard visibility icons)
  PasswordObscureIcon? get passwordObscureIcon;

  /// Design size for responsive scaling.
  ///
  /// Used by [CoreScreenUtils] to calculate responsive dimensions.
  /// Default: Size(428, 926) - iPhone 14 Pro Max dimensions
  Size get designSize;
}

/// Mixin to provide default values for optional [CoreKitConfig] properties.
///
/// Implement this mixin with [CoreKitConfig] to avoid implementing
/// all optional properties.
///
/// Example:
/// ```dart
/// class MyConfig extends CoreKitConfig with CoreKitConfigDefaults {
///   // Only implement required properties
/// }
/// ```
mixin CoreKitConfigDefaults implements CoreKitConfig {
  /// Returns null - uses [AppbarConfig] defaults
  @override
  AppbarConfig? get appbarConfig => null;

  /// Returns null - uses English defaults
  @override
  PermissionHelperConfig? get permissionHelperConfig => null;

  /// Returns null - uses red/green/black defaults
  @override
  PermissionHadlerColors? get permissionHandlerColors => null;

  /// Returns null - uses standard visibility icons
  @override
  PasswordObscureIcon? get passwordObscureIcon => null;

  /// Returns Size(428, 926) - iPhone 14 Pro Max dimensions
  @override
  Size get designSize => const Size(428, 926);
}

/// CoreKit - Main application wrapper widget.
///
/// Handles initialization of all CoreKit services including:
/// - Dio service for network requests
/// - Responsive screen utilities
/// - App bar configuration
/// - Permission handling
/// - Theme and navigation
///
/// The [config] parameter is required and should implement [CoreKitConfig].
/// Use [CoreKitConfigDefaults] mixin for optional properties.
///
/// If [navigatorKey] is not provided, one will be created automatically.
/// Access the navigator key anywhere via [CoreKit.navigatorKey].
///
/// Example using standard routing:
/// ```dart
/// CoreKit(
///   config: MyAppConfig(),
///   home: HomeScreen(),
///   theme: ThemeData(...),
/// )
/// ```
///
/// Example using go_router:
/// ```dart
/// CoreKit.router(
///   config: MyAppConfig(),
///   routerConfig: appRouter.config(),
///   theme: ThemeData(...),
/// )
/// ```
class CoreKit extends StatefulWidget {
  /// Required configuration implementing [CoreKitConfig].
  final CoreKitConfig config;

  /// Application theme.
  final ThemeData? theme;

  /// Dark theme for dark mode support.
  final ThemeData? darkTheme;

  /// Theme mode (system, light, or dark).
  final ThemeMode? themeMode;

  /// Application title shown in task switcher.
  final String title;

  /// Restoration scope ID for state restoration.
  final String? restorationScopeId;

  /// Default locale for the application.
  final Locale? locale;

  /// Localization delegates for translations.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Callback for resolving list of locales.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// Callback for resolving a single locale.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// List of supported locales.
  final Iterable<Locale> supportedLocales;

  /// Show performance overlay (debug only).
  final bool showPerformanceOverlay;

  /// Checkerboard offscreen layers (debug only).
  final bool checkerboardOffscreenLayers;

  /// Checkerboard raster cache images (debug only).
  final bool checkerboardRasterCacheImages;

  /// Show semantics debugger (debug only).
  final bool showSemanticsDebugger;

  /// Show debug banner.
  final bool debugShowCheckedModeBanner;

  /// Keyboard shortcuts map.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Actions map.
  final Map<Type, Action<Intent>>? actions;

  /// Show material grid (debug only).
  final bool debugShowMaterialGrid;

  /// Home widget (for standard routing, not used with .router).
  final Widget? home;

  /// Routes map (for standard routing, not used with .router).
  final Map<String, WidgetBuilder> routes;

  /// Initial route (for standard routing, not used with .router).
  final String? initialRoute;

  /// Route generator callback (for standard routing, not used with .router).
  final RouteFactory? onGenerateRoute;

  /// Unknown route handler (for standard routing, not used with .router).
  final RouteFactory? onUnknownRoute;

  /// Navigator observers (for standard routing, not used with .router).
  final List<NavigatorObserver> navigatorObservers;

  /// Router configuration (required for .router constructor).
  final RouterConfig<Object>? routerConfig;

  /// Ensure screen size is initialized.
  final bool ensureScreenSize;

  /// Access the navigator key created by CoreKit.
  ///
  /// Available immediately after CoreKit widget is initialized.
  /// Use this for navigation from anywhere in the app:
  /// ```dart
  /// CoreKit.navigatorKey.currentState?.push(...)
  /// CoreKit.navigatorKey.currentContext  // for theme access
  /// ```
  static GlobalKey<NavigatorState> get navigatorKey =>
      coreKitInstance.navigatorKey;

  const CoreKit({
    super.key,
    required this.config,
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
    this.shortcuts,
    this.actions,
    this.debugShowMaterialGrid = false,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
  }) : routerConfig = null;

  const CoreKit.router({
    super.key,
    required this.config,
    required this.routerConfig,
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
  State<CoreKit> createState() => coreKitInstanceState();
}

// ignore: camel_case_types
class coreKitInstanceState extends State<CoreKit> {
  bool _initialized = false;
  late final GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
    final instance = coreKitInstance;
    final config = widget.config;
    instance.navigatorKey = _navigatorKey;
    instance.imageBaseUrl = config.imageBaseUrl;
    instance.designSize = config.designSize;
    instance.dioServiceConfig = config.dioConfig;
    instance.tokenProvider = config.tokenProvider;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeWithContext(context);
  }

  void _initializeWithContext(BuildContext context) {
    if (_initialized) return;
    CoreScreenUtils.init(context, () {
      final instance = coreKitInstance;
      final config = widget.config;
      if (instance.appbarConfig.onBack == null) {
        instance.appbarConfig = instance.appbarConfig.copyWith(
          onBack: () => instance.navigatorKey.currentState?.pop(),
        );
      }
      DioService.init(
        config: config.dioConfig,
        tokenProvider: config.tokenProvider,
      );
      setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Show a loading screen or splash while initializing
      return MaterialApp(
        navigatorKey: _navigatorKey,
        theme: widget.theme,
        darkTheme: widget.darkTheme,
        themeMode: widget.themeMode,
        title: widget.title,
        home: Scaffold(
          backgroundColor:
              widget.theme?.scaffoldBackgroundColor ?? Colors.white,
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.routerConfig != null) {
      return MaterialApp.router(
        key: widget.key,
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
        routerConfig: widget.routerConfig!,
      );
    }

    return MaterialApp(
      key: widget.key,
      navigatorKey: _navigatorKey,
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
      home: widget.home,
      routes: widget.routes,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers: widget.navigatorObservers,
    );
  }
}
