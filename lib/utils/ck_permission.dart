import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:flutter/material.dart' as material show showDialog;
import 'package:universal_io/io.dart';

/// A modern, developer-friendly permission manager for CoreKit.
///
/// Easily ensure permissions before triggering hardware features:
/// ```dart
/// final status = await CkPermission.camera.ensure();
/// if (!status) return;
///
/// final picked = await ImagePicker().pickImage(
///   source: ImageSource.camera,
/// );
/// ```
class CkPermission {
  /// The underlying [Permission] from `permission_handler`.
  final Permission permission;

  /// Creates a [CkPermission] instance wrapping a [Permission].
  const CkPermission(this.permission);

  /// Creates a [CkPermission] instance from a [Permission].
  const CkPermission.from(this.permission);

  // ---------------------------------------------------------------------------
  // Static Pre-defined Permission Instances
  // ---------------------------------------------------------------------------

  /// Camera permission (`Permission.camera`).
  static const CkPermission camera = CkPermission(Permission.camera);

  /// Photos / Photo Library permission (`Permission.photos`).
  static const CkPermission photos = CkPermission(Permission.photos);

  /// Photos Add-Only permission (`Permission.photosAddOnly`).
  static const CkPermission photosAddOnly = CkPermission(
    Permission.photosAddOnly,
  );

  /// Storage permission (`Permission.storage`).
  static const CkPermission storage = CkPermission(Permission.storage);

  /// Microphone permission (`Permission.microphone`).
  static const CkPermission microphone = CkPermission(Permission.microphone);

  /// General Location permission (`Permission.location`).
  static const CkPermission location = CkPermission(Permission.location);

  /// Location when in use permission (`Permission.locationWhenInUse`).
  static const CkPermission locationWhenInUse = CkPermission(
    Permission.locationWhenInUse,
  );

  /// Location always permission (`Permission.locationAlways`).
  static const CkPermission locationAlways = CkPermission(
    Permission.locationAlways,
  );

  /// Notification permission (`Permission.notification`).
  static const CkPermission notification = CkPermission(
    Permission.notification,
  );

  /// Contacts permission (`Permission.contacts`).
  static const CkPermission contacts = CkPermission(Permission.contacts);

  /// SMS permission (`Permission.sms`).
  static const CkPermission sms = CkPermission(Permission.sms);

  /// Phone permission (`Permission.phone`).
  static const CkPermission phone = CkPermission(Permission.phone);

  /// Calendar permission (`Permission.calendar`).
  @Deprecated('Use [calendarFullAccess] or [calendarWriteOnly] instead.')
  // ignore: deprecated_member_use
  static const CkPermission calendar = CkPermission(Permission.calendar);

  /// Calendar full access permission (`Permission.calendarFullAccess`).
  static const CkPermission calendarFullAccess = CkPermission(
    Permission.calendarFullAccess,
  );

  /// Calendar write-only permission (`Permission.calendarWriteOnly`).
  static const CkPermission calendarWriteOnly = CkPermission(
    Permission.calendarWriteOnly,
  );

  /// Reminders permission (`Permission.reminders`).
  static const CkPermission reminders = CkPermission(Permission.reminders);

  /// Sensors permission (`Permission.sensors`).
  static const CkPermission sensors = CkPermission(Permission.sensors);

  /// Sensors always permission (`Permission.sensorsAlways`).
  static const CkPermission sensorsAlways = CkPermission(
    Permission.sensorsAlways,
  );

  /// Speech recognition permission (`Permission.speech`).
  static const CkPermission speech = CkPermission(Permission.speech);

  /// Bluetooth permission (`Permission.bluetooth`).
  static const CkPermission bluetooth = CkPermission(Permission.bluetooth);

  /// Bluetooth scan permission (`Permission.bluetoothScan`).
  static const CkPermission bluetoothScan = CkPermission(
    Permission.bluetoothScan,
  );

  /// Bluetooth advertise permission (`Permission.bluetoothAdvertise`).
  static const CkPermission bluetoothAdvertise = CkPermission(
    Permission.bluetoothAdvertise,
  );

  /// Bluetooth connect permission (`Permission.bluetoothConnect`).
  static const CkPermission bluetoothConnect = CkPermission(
    Permission.bluetoothConnect,
  );

  /// Nearby Wi-Fi devices permission (`Permission.nearbyWifiDevices`).
  static const CkPermission nearbyWifiDevices = CkPermission(
    Permission.nearbyWifiDevices,
  );

  /// Media Library permission (`Permission.mediaLibrary`).
  static const CkPermission mediaLibrary = CkPermission(
    Permission.mediaLibrary,
  );

  /// Audio permission (`Permission.audio`).
  static const CkPermission audio = CkPermission(Permission.audio);

  /// Videos permission (`Permission.videos`).
  static const CkPermission videos = CkPermission(Permission.videos);

  /// Ignore battery optimizations permission (`Permission.ignoreBatteryOptimizations`).
  static const CkPermission ignoreBatteryOptimizations = CkPermission(
    Permission.ignoreBatteryOptimizations,
  );

  /// Access media location permission (`Permission.accessMediaLocation`).
  static const CkPermission accessMediaLocation = CkPermission(
    Permission.accessMediaLocation,
  );

  /// Activity recognition permission (`Permission.activityRecognition`).
  static const CkPermission activityRecognition = CkPermission(
    Permission.activityRecognition,
  );

  /// Manage external storage permission (`Permission.manageExternalStorage`).
  static const CkPermission manageExternalStorage = CkPermission(
    Permission.manageExternalStorage,
  );

  /// System alert window permission (`Permission.systemAlertWindow`).
  static const CkPermission systemAlertWindow = CkPermission(
    Permission.systemAlertWindow,
  );

  /// Request install packages permission (`Permission.requestInstallPackages`).
  static const CkPermission requestInstallPackages = CkPermission(
    Permission.requestInstallPackages,
  );

  /// App tracking transparency permission (`Permission.appTrackingTransparency`).
  static const CkPermission appTrackingTransparency = CkPermission(
    Permission.appTrackingTransparency,
  );

  /// Critical alerts permission (`Permission.criticalAlerts`).
  static const CkPermission criticalAlerts = CkPermission(
    Permission.criticalAlerts,
  );

  /// Access notification policy permission (`Permission.accessNotificationPolicy`).
  static const CkPermission accessNotificationPolicy = CkPermission(
    Permission.accessNotificationPolicy,
  );

  /// Schedule exact alarm permission (`Permission.scheduleExactAlarm`).
  static const CkPermission scheduleExactAlarm = CkPermission(
    Permission.scheduleExactAlarm,
  );

  /// Background refresh permission (`Permission.backgroundRefresh`).
  static const CkPermission backgroundRefresh = CkPermission(
    Permission.backgroundRefresh,
  );

  /// Assistant permission (`Permission.assistant`).
  static const CkPermission assistant = CkPermission(Permission.assistant);

  // ---------------------------------------------------------------------------
  // Core Methods
  // ---------------------------------------------------------------------------

  /// Checks if the permission is granted. If not, requests it.
  /// If permanently denied, shows the settings dialog if [showDialog] is true.
  ///
  /// Returns `true` if granted (or limited on iOS/Android), `false` otherwise.
  Future<bool> ensure({bool showDialog = true, BuildContext? context}) async {
    var isAlreadyGranted = false;

    if ((permission == Permission.photos || permission == Permission.storage) &&
        Platform.isAndroid) {
      isAlreadyGranted =
          (await Permission.mediaLibrary.status).isGranted ||
          (await permission.status).isGranted;
    } else {
      isAlreadyGranted = (await permission.status).isGranted;
    }

    if (isAlreadyGranted) {
      return true;
    }

    CkLogger.warning(
      'Current permission status for $name is not granted, requesting permission...',
      tag: 'Permission Handler',
    );

    final requestStatus = await permission.request();

    if (requestStatus.isGranted || requestStatus.isLimited) {
      return true;
    }

    CkLogger.warning(
      'Permission $name is ${requestStatus.name}',
      tag: 'Permission Handler',
    );

    if (requestStatus.isPermanentlyDenied && showDialog) {
      await this.showDialog(context: context);
    }

    return false;
  }

  /// The current [PermissionStatus].
  Future<PermissionStatus> get status => permission.status;

  /// Returns `true` if the permission is granted.
  Future<bool> get isGranted async {
    if ((permission == Permission.photos || permission == Permission.storage) &&
        Platform.isAndroid) {
      final isMediaGranted = (await Permission.mediaLibrary.status).isGranted;
      if (isMediaGranted) return true;
    }
    return (await permission.status).isGranted;
  }

  /// Returns `true` if the permission is denied.
  Future<bool> get isDenied => permission.isDenied;

  /// Returns `true` if the permission is permanently denied.
  Future<bool> get isPermanentlyDenied => permission.isPermanentlyDenied;

  /// Returns `true` if the permission is restricted (e.g. by parental controls).
  Future<bool> get isRestricted => permission.isRestricted;

  /// Returns `true` if the permission is limited (e.g. limited photo library access on iOS).
  Future<bool> get isLimited => permission.isLimited;

  /// Requests the permission from the operating system.
  Future<PermissionStatus> request() => permission.request();

  /// Displays the permanently denied dialog guiding the user to open app settings.
  Future<dynamic> showDialog({BuildContext? context}) {
    final ctx = context ?? coreKitInstance.navigatorKey.currentState?.context;
    if (ctx == null) {
      CkLogger.warning(
        'Cannot show permission dialog: no BuildContext available.',
        tag: 'Permission Handler',
      );
      return Future.value(null);
    }

    final errorColor = coreKitInstance.permissionHandlerColors.errorColor;
    final actionColor = coreKitInstance.permissionHandlerColors.actionColor;
    final normalColor = coreKitInstance.permissionHandlerColors.normalColor;
    final fontFamily = coreKitInstance.fontFamily;

    return material.showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
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
                        '❌ $name ${coreKitInstance.permissionHelperConfig.permissionIsPermanentlyDenied}\n\n',
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
              if (coreKitInstance.appbarConfig.getBack != null) {
                coreKitInstance.appbarConfig.getBack?.call();
              } else {
                Navigator.of(dialogCtx).pop();
              }
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
            onPressed: () {
              if (coreKitInstance.appbarConfig.getBack != null) {
                coreKitInstance.appbarConfig.getBack?.call();
              } else {
                Navigator.of(dialogCtx).pop();
              }
            },
            child: Text(
              coreKitInstance.permissionHelperConfig.cancel,
              style: TextStyle(fontFamily: fontFamily, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Friendly display name for the permission.
  String get name => _getPermissionName(permission);

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
      case Permission.manageExternalStorage:
        return 'Storage';
      case Permission.notification:
      case Permission.accessNotificationPolicy:
      case Permission.criticalAlerts:
        return 'Notifications';
      case Permission.contacts:
        return 'Contacts';
      case Permission.sms:
        return 'SMS';
      case Permission.phone:
        return 'Phone';
      // ignore: deprecated_member_use
      case Permission.calendar:
      case Permission.calendarFullAccess:
      case Permission.calendarWriteOnly:
        return 'Calendar';
      case Permission.reminders:
        return 'Reminders';
      case Permission.sensors:
      case Permission.sensorsAlways:
        return 'Sensors';
      case Permission.speech:
        return 'Speech Recognition';
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
        return 'Bluetooth';
      case Permission.mediaLibrary:
        return 'Media Library';
      case Permission.audio:
        return 'Audio';
      case Permission.videos:
        return 'Videos';
      case Permission.appTrackingTransparency:
        return 'App Tracking';
      case Permission.activityRecognition:
        return 'Activity Recognition';
      default:
        final raw = permission.toString().split('.').last;
        // Capitalize first letter
        if (raw.isNotEmpty) {
          return raw[0].toUpperCase() + raw.substring(1);
        }
        return raw;
    }
  }

  // ---------------------------------------------------------------------------
  // Static Helper Methods
  // ---------------------------------------------------------------------------

  /// Ensures a standard [Permission].
  static Future<bool> ensurePermission(
    Permission permission, {
    bool showDialog = true,
    BuildContext? context,
  }) {
    return CkPermission(
      permission,
    ).ensure(showDialog: showDialog, context: context);
  }

  /// Ensures multiple [CkPermission] permissions concurrently.
  static Future<Map<CkPermission, bool>> ensureMultiple(
    List<CkPermission> permissions, {
    bool showDialog = true,
    BuildContext? context,
  }) async {
    final results = <CkPermission, bool>{};
    for (final perm in permissions) {
      results[perm] = await perm.ensure(
        showDialog: showDialog,
        context: context,
      );
    }
    return results;
  }

  /// Opens the operating system app settings page.
  static Future<bool> openSettings() => openAppSettings();

  /// Displays the permission denied dialog for any [Permission].
  static Future<dynamic> showPermissionDialog(
    Permission permission, {
    BuildContext? context,
  }) {
    return CkPermission(permission).showDialog(context: context);
  }

  /// Gets the friendly name of any [Permission].
  static String getPermissionName(Permission permission) =>
      _getPermissionName(permission);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CkPermission && other.permission == permission);

  @override
  int get hashCode => permission.hashCode;

  @override
  String toString() => 'CkPermission($name)';
}

/// Extension on [Permission] to provide easy access to `.ensure()`.
extension CkPermissionExtension on Permission {
  /// Checks if the permission is granted, requests if needed, and shows settings dialog if permanently denied.
  Future<bool> ensure({bool showDialog = true, BuildContext? context}) {
    return CkPermission(this).ensure(showDialog: showDialog, context: context);
  }

  /// Wraps this [Permission] in a [CkPermission].
  CkPermission get toCkPermission => CkPermission(this);
}

/// Alias for [CkPermissionHelperConfig] for configuring permission dialog copy.
typedef CkPermissionConfig = CkPermissionHelperConfig;
