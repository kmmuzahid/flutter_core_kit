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

  // Singleton instance
  static final CoreKit _instance = CoreKit._();
  static CoreKit get instance => _instance;

  // Configuration fields
  late Color backgroundColor;
  late NavigationBack back;
  String? fontFamily;
  TextStyle? defaultTextStyle;
  late String imageBaseUrl;
  String? backButtonAsset;
  late GlobalKey<NavigatorState> navigatorKey;
  late Color primaryColor;
  late Color onPrimaryColor;
  late Color secondaryColor;
  late Color outlineColor;
  late Color surfaceBG;

  PermissionHadlerColors permissionHandlerColors = PermissionHadlerColors(
    errorColor: Colors.red,
    actionColor: Colors.green,
    normalColor: Colors.black,
  );

  void init({
    required BuildContext context,
    required Color backgroundColor,
    required NavigationBack back,
    required String imageBaseUrl,
    required GlobalKey<NavigatorState> navigatorKey,
    required Color primaryColor,
    required Color onPrimaryColor,
    required Color secondaryColor,
    required Color outlineColor,
    required Color surfaceBG,
    required DioServiceConfig dioServiceConfig,
    required TokenProvider tokenProvider,
    String? fontFamily,
    TextStyle? defaultTextStyle,
    String? backButtonAsset,
    PermissionHadlerColors? permissionHandlerColors,
  }) {
    this.backgroundColor = backgroundColor;
    this.back = back;
    this.imageBaseUrl = imageBaseUrl;
    this.navigatorKey = navigatorKey;
    this.primaryColor = primaryColor;
    this.onPrimaryColor = onPrimaryColor;
    this.secondaryColor = secondaryColor;
    this.outlineColor = outlineColor;
    this.surfaceBG = surfaceBG;
    this.fontFamily = fontFamily;
    this.defaultTextStyle = defaultTextStyle;
    this.backButtonAsset = backButtonAsset;
    CoreScreenUtils.init(context);
    if (permissionHandlerColors != null) {
      this.permissionHandlerColors = permissionHandlerColors;
    }
    DioService.instance.init(config: dioServiceConfig, tokenProvider: tokenProvider);
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
