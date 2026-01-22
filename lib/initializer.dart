/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:18:19
 * @Email: km.muzahid@gmail.com
 */

import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

typedef NavigationBack = void Function();

class CoreKit {
  // Private constructor
  CoreKit._();
  static bool _isInitialized = false;

  // Singleton instance
  static final CoreKit _instance = CoreKit._();
  static CoreKit get instance => _instance;

  ThemeData get theme => Theme.of(navigatorKey.currentState!.context);

  // Configuration fields


  late NavigationBack back;

  String? get fontFamily => theme.textTheme.bodyMedium?.fontFamily;

  TextStyle? get defaultTextStyle => theme.textTheme.bodyMedium;

  late String imageBaseUrl;
  Widget? backButton;
  late GlobalKey<ScaffoldMessengerState> navigatorKey;

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
    required NavigationBack back,
    required String imageBaseUrl,
    required GlobalKey<ScaffoldMessengerState> navigatorKey,
    required DioServiceConfig dioServiceConfig,
    required TokenProvider tokenProvider,
    Widget? backButton,
    PermissionHadlerColors? permissionHandlerColors,
    Widget? child,
    Size designSize = const Size(428, 926),
  }) {
    if (_isInitialized) {
      return _SetChild(child: child ?? SizedBox.shrink());
    }
    _instance.designSize = designSize;
    _isInitialized = true;
    _instance.navigatorKey = navigatorKey;
    _instance.back = back;
    _instance.imageBaseUrl = imageBaseUrl;
    _instance.backButton = backButton;
if (permissionHandlerColors != null) {
      _instance.permissionHandlerColors = permissionHandlerColors;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        CoreScreenUtils.init(context);
        
        DioService.init(config: dioServiceConfig, tokenProvider: tokenProvider);

        return _SetChild(child: child ?? SizedBox.shrink());
      },
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
  const _SetChild({super.key, required this.child});
  final Widget child;

  @override
  State<_SetChild> createState() => _SetChildState();
}

class _SetChildState extends State<_SetChild> {
  Widget child = SizedBox.shrink();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        child = widget.child;
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
