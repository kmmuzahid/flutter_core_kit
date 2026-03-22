/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 15:37:50
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

class CommonAlert {
  CommonAlert({
    required this.title,
    required this.onTap,
    this.content,
    this.disableActionButton = false,
    this.disableCancelButton = false,
    this.actionButtonTittle,
    this.cancelButtonTittle,
    this.cancelButtonColor,
    this.actionButtonColor,
    this.actionTitleColor,
    this.cancelTitleColor,
  }) {
    _alertBuilder();
  }
  final String title;
  String? actionButtonTittle;
  String? cancelButtonTittle;
  final Function onTap;
  final Widget? content;
  final bool disableActionButton;
  final bool disableCancelButton;
  final Color? cancelButtonColor;
  final Color? actionButtonColor;
  final Color? actionTitleColor;
  final Color? cancelTitleColor;

  Future<dynamic> _alertBuilder() {
    return showDialog(
      context: coreKitInstance.navigatorKey.currentContext!,
      builder: (c) => AlertDialog(
        title: Text(title, style: coreKitInstance.defaultTextStyle),
        actionsAlignment: MainAxisAlignment.center,
        content: content,
        actions: [
          if (disableCancelButton == false)
            CommonButton(
              titleText: cancelButtonTittle ?? "No",
              buttonWidth: 70,
              buttonHeight: 35,
              buttonColor: cancelButtonColor ?? Colors.red,
              titleColor: cancelTitleColor ?? Colors.white,
              onTap: coreKitInstance.appbarConfig.getBack,
            ),
          if (disableActionButton == false)
            IntrinsicWidth(
              child: CommonButton(
                titleText: actionButtonTittle ?? "Yes",
                buttonHeight: 35,
                buttonColor: actionButtonColor ?? Colors.green,
                titleColor: actionTitleColor ?? Colors.white,
                onTap: () {
                  coreKitInstance.appbarConfig.getBack?.call();
                  onTap();
                },
              ),
            ),
        ],
      ),
    );
  }
}
