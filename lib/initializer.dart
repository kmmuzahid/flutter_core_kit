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

class CoreKit {
  // Private constructor
  CoreKit._();

  PermissionHelperConfig permissionHelperConfig = PermissionHelperConfig();

  // Singleton instance
  static final CoreKit _instance = CoreKit._();
  static CoreKit get instance => _instance;

  ThemeData get theme => Theme.of(navigatorKey.currentContext!);

  // Configuration fields

  late AppbarConfig appbarConfig;

  String? get fontFamily => theme.textTheme.bodyMedium?.fontFamily;

  PasswordObscureIcon passWordObscureIcon = PasswordObscureIcon(
    padding: const EdgeInsetsDirectional.only(end: 10),
    show: const Icon(Icons.visibility, size: 20),
    hide: const Icon(Icons.visibility_off, size: 20),
  );

  TextStyle? get defaultTextStyle => theme.textTheme.bodyMedium;

  late String imageBaseUrl;

  late GlobalKey<NavigatorState> navigatorKey;

  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get primaryColor => theme.primaryColor;
  Color get onPrimaryColor => theme.colorScheme.onPrimary;
  Color get secondaryColor => theme.colorScheme.secondary;
  Color get outlineColor => theme.colorScheme.outline;
  Color get surfaceBG => theme.colorScheme.surface;
  late Size designSize;

  PermissionHadlerColors permissionHandlerColors = PermissionHadlerColors(
    errorColor: Colors.red,
    actionColor: Colors.green,
    normalColor: Colors.black,
  );

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
    // _instance.designSize = designSize;

    // if (permissionHelperStrings != null) {
    //   _instance.permissionHelperConfig = permissionHelperStrings;
    // }
    // _instance.navigatorKey = navigatorKey;
    // _instance.imageBaseUrl = imageBaseUrl;
    // if (permissionHandlerColors != null) {
    //   _instance.permissionHandlerColors = permissionHandlerColors;
    // }
    // _instance.appbarConfig = appbarConfig ?? AppbarConfig();

    return _SetChild(
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

class _SetChild extends StatefulWidget {
  const _SetChild({
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
  State<_SetChild> createState() => _SetChildState();
}

class _SetChildState extends State<_SetChild> {
  final CoreKit _instance = CoreKit.instance;

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
        onBack: () {
          Navigator.pop(context);
        },
      );
        }
    DioService.init(config: widget.dioServiceConfig, tokenProvider: widget.tokenProvider);
        setState(() {
          isInitialized = true;
        });
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
