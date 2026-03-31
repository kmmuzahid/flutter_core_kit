import 'dart:io';

import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

/// A helper class for handling permission requests.
class PermissionHelper {
  const PermissionHelper();

  /// Requests permission from the user.
  ///
  /// [permission] The permission to request.
  ///
  /// Returns `true` if the permission is granted, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final status = await PermissionHelper.request(Permission.camera);
  /// ```
  static Future<bool> request(Permission permission) async {
    var currentStatus = false;

    if ((permission == Permission.photos || permission == Permission.storage) &&
        Platform.isAndroid) {
      currentStatus = (await Permission.mediaLibrary.status).isGranted;
    } else {
      currentStatus = (await permission.status).isGranted;
    }

    if (!currentStatus) {
      AppLogger.warning(
        'Sorry! Current Permission Status is $currentStatus, need to take permission',
        tag: 'Permission Handler',
      );

      final status = await permission.request();

      if (!status.isGranted) {
        AppLogger.warning(
          'Sorry! Permission No ${permission.value} is ${status.name}',
          tag: 'Permission Handler',
        );

        if (status.isPermanentlyDenied) {
          _dialog(permission);
        }

        return false;
      }
    }

    return true;
  }

  static Future<dynamic> _dialog(Permission permission) {
    final errorColor = coreKitInstance.permissionHandlerColors.errorColor;
    final actionColor = coreKitInstance.permissionHandlerColors.actionColor;
    final normalColor = coreKitInstance.permissionHandlerColors.normalColor;
    final fontFamily = coreKitInstance.fontFamily;

    final navigatorState = coreKitInstance.navigatorKey.currentState;
    if (navigatorState == null) {
      return Future.value(null);
    }

    return showDialog(
      context: navigatorState.context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: errorColor),
            const SizedBox(width: 8),
            Text(
              coreKitInstance.permissionHelperConfig.permissionDenied,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                color: errorColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontFamily: fontFamily,
                ),
                children: [
                  TextSpan(
                    text:
                        '❌ ${_getPermissionName(permission)} ${coreKitInstance.permissionHelperConfig.permissionIsPermanentlyDenied}\n\n',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        '✅ ${coreKitInstance.permissionHelperConfig.toFixThisPleaseGoTo} ',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: normalColor,
                    ),
                  ),
                  TextSpan(
                    text: coreKitInstance.permissionHelperConfig.openSettings,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: actionColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ${coreKitInstance.permissionHelperConfig.andAllowThePermissionManually}',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: normalColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              openAppSettings();
              coreKitInstance.appbarConfig.getBack?.call();
            },
            icon: Icon(Icons.settings, color: actionColor),
            label: Text(
              coreKitInstance.permissionHelperConfig.openSettings,
              style: TextStyle(
                fontFamily: fontFamily,
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: coreKitInstance.appbarConfig.getBack,
            child: Text(
              coreKitInstance.permissionHelperConfig.cancel,
              style: TextStyle(fontFamily: fontFamily, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  static String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.location:
      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return 'Location';
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.photos:
      case Permission.photosAddOnly:
        return 'Photos';
      case Permission.storage:
        return 'Storage';
      case Permission.notification:
        return 'Notifications';
      case Permission.contacts:
        return 'Contacts';
      case Permission.sms:
        return 'SMS';
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
        return 'Bluetooth';
      case Permission.mediaLibrary:
        return 'Media Library';
      default:
        return permission.toString().split('.').last; // fallback
    }
  }
}

class PermissionHelperConfig {
  final String permissionDenied;
  final String openSettings;
  final String cancel;
  final String permissionIsPermanentlyDenied;
  final String toFixThisPleaseGoTo;
  final String andAllowThePermissionManually;

  const PermissionHelperConfig({
    this.permissionDenied = 'Permission Denied',
    this.openSettings = 'Open Settings',
    this.cancel = 'Cancel',
    this.permissionIsPermanentlyDenied = 'Permission is permanently denied.',
    this.toFixThisPleaseGoTo = 'To fix this, please go to ',
    this.andAllowThePermissionManually = 'and allow the permission manually.',
  });
}
