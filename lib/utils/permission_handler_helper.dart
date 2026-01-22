import 'dart:io';

import 'package:core_kit/initializer.dart';
import 'package:core_kit/utils/app_log.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerHelper {
  const PermissionHandlerHelper({required this.permission});
  final Permission permission;

  Future<bool> getStatus() async {
    bool currentStatus = false;

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
          _dialog();
        }

        return false;
      }
    }

    return true;
  }

  Future<dynamic> _dialog() {
    final errorColor = CoreKit.instance.permissionHandlerColors.errorColor;
    final actionColor = CoreKit.instance.permissionHandlerColors.actionColor;
    final normalColor = CoreKit.instance.permissionHandlerColors.normalColor;
    final fontFamily = CoreKit.instance.fontFamily;

    return showDialog(
      context: CoreKit.instance.scaffoldMessangerKey.currentState!.context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: errorColor),
            const SizedBox(width: 8),
            Text(
              'Permission Denied',
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
                style: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: fontFamily),
                children: [
                  TextSpan(
                    text:
                        '❌ ${_getPermissionName(permission)} permission is permanently denied.\n\n',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '✅ To fix this, please go to ',
                    style: TextStyle(fontFamily: fontFamily, color: normalColor),
                  ),
                  TextSpan(
                    text: 'App Settings',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: actionColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' and allow the permission manually.',
                    style: TextStyle(fontFamily: fontFamily, color: normalColor),
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
              CoreKit.instance.back();
            },
            icon: Icon(Icons.settings, color: actionColor),
            label: Text(
              'Open Settings',
              style: TextStyle(
                fontFamily: fontFamily,
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: CoreKit.instance.back,
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: fontFamily, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionName(Permission permission) {
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
