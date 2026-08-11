import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

/// A helper class for handling permission requests.
///
/// For a more modern syntax, use [CkPermission] or `Permission.ensure()`, e.g.:
/// ```dart
/// final status = await CkPermission.camera.ensure();
/// // or
/// final status = await Permission.camera.ensure();
/// ```
@Deprecated('Use CkPermission. Example: CkPermission.camera.ensure()')
class CkPermissionHelper {
  CkPermissionHelper._();

  /// Requests permission using [CkPermission.ensure].
  static Future<bool> request(
    Permission permission, {
    bool showDialog = true,
    BuildContext? context,
  }) {
    return CkPermission(
      permission,
    ).ensure(showDialog: showDialog, context: context);
  }

  /// Displays the permission dialog for permanently denied permissions.
  static Future<dynamic> showDialog(
    Permission permission, {
    BuildContext? context,
  }) {
    return CkPermission(permission).showDialog(context: context);
  }
}

/// Configuration for the permission helper dialog.
class CkPermissionHelperConfig {
  final String permissionDenied;
  final String openSettings;
  final String cancel;
  final String permissionIsPermanentlyDenied;
  final String toFixThisPleaseGoTo;
  final String andAllowThePermissionManually;

  const CkPermissionHelperConfig({
    this.permissionDenied = 'Permission Denied',
    this.openSettings = 'Open Settings',
    this.cancel = 'Cancel',
    this.permissionIsPermanentlyDenied = 'Permission is permanently denied.',
    this.toFixThisPleaseGoTo = 'To fix this, please go to ',
    this.andAllowThePermissionManually = 'and allow the permission manually.',
  });
}
