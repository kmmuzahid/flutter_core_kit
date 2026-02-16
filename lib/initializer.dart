/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:18:19
 * @Email: km.muzahid@gmail.com
 */

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

  late NavigationBack back;

  String? get fontFamily => theme.textTheme.bodyMedium?.fontFamily;

  PasswordObscureIcon passWordObscureIcon = PasswordObscureIcon(
    padding: EdgeInsetsDirectional.only(end: 10),
    show: const Icon(Icons.visibility, size: 20),
    hide: const Icon(Icons.visibility_off, size: 20),
  );

  TextStyle? get defaultTextStyle => theme.textTheme.bodyMedium;

  late String imageBaseUrl;
  Widget? backButton;
  Icon backIcon = const Icon(Icons.arrow_back_ios, size: 25);

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
    required NavigationBack back,
    required String imageBaseUrl,
    Icon backIcon = const Icon(Icons.arrow_back_ios, size: 25),
    required GlobalKey<NavigatorState> navigatorKey,
    required DioServiceConfig dioServiceConfig,
    required TokenProvider tokenProvider,
    PasswordObscureIcon? passwordObscureIcon,
    Widget? backButton,
    PermissionHadlerColors? permissionHandlerColors,
    Widget? child,
    Size designSize = const Size(428, 926),
    PermissionHelperConfig? permissionHelperStrings,
  }) {
    _instance.designSize = designSize;
    _instance.backIcon = backIcon;

    if (permissionHelperStrings != null) {
      _instance.permissionHelperConfig = permissionHelperStrings;
    } 
    _instance.navigatorKey = navigatorKey;
    _instance.back = back;
    _instance.imageBaseUrl = imageBaseUrl;
    _instance.backButton = backButton;
    if (permissionHandlerColors != null) {
      _instance.permissionHandlerColors = permissionHandlerColors;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        CoreScreenUtils.init(context).then((value) {
          DioService.init(config: dioServiceConfig, tokenProvider: tokenProvider);
          if (passwordObscureIcon != null) {
            _instance.passWordObscureIcon = passwordObscureIcon;
          }
        });

        return child ?? SizedBox.shrink();
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
