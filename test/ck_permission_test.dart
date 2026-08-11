import 'package:core_kit/core_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkPermission Tests', () {
    test('predefined static instances match underlying Permission', () {
      expect(CkPermission.camera.permission, Permission.camera);
      expect(CkPermission.photos.permission, Permission.photos);
      expect(CkPermission.photosAddOnly.permission, Permission.photosAddOnly);
      expect(CkPermission.storage.permission, Permission.storage);
      expect(CkPermission.microphone.permission, Permission.microphone);
      expect(CkPermission.location.permission, Permission.location);
      expect(CkPermission.locationWhenInUse.permission,
          Permission.locationWhenInUse);
      expect(CkPermission.locationAlways.permission, Permission.locationAlways);
      expect(CkPermission.notification.permission, Permission.notification);
      expect(CkPermission.contacts.permission, Permission.contacts);
      expect(CkPermission.sms.permission, Permission.sms);
      expect(CkPermission.phone.permission, Permission.phone);
      expect(CkPermission.calendar.permission, Permission.calendar);
      expect(CkPermission.calendarFullAccess.permission,
          Permission.calendarFullAccess);
      expect(CkPermission.calendarWriteOnly.permission,
          Permission.calendarWriteOnly);
      expect(CkPermission.reminders.permission, Permission.reminders);
      expect(CkPermission.sensors.permission, Permission.sensors);
      expect(CkPermission.sensorsAlways.permission, Permission.sensorsAlways);
      expect(CkPermission.speech.permission, Permission.speech);
      expect(CkPermission.bluetooth.permission, Permission.bluetooth);
      expect(CkPermission.bluetoothScan.permission, Permission.bluetoothScan);
      expect(CkPermission.bluetoothAdvertise.permission,
          Permission.bluetoothAdvertise);
      expect(CkPermission.bluetoothConnect.permission,
          Permission.bluetoothConnect);
      expect(
          CkPermission.nearbyWifiDevices.permission, Permission.nearbyWifiDevices);
      expect(CkPermission.mediaLibrary.permission, Permission.mediaLibrary);
      expect(CkPermission.audio.permission, Permission.audio);
      expect(CkPermission.videos.permission, Permission.videos);
      expect(CkPermission.ignoreBatteryOptimizations.permission,
          Permission.ignoreBatteryOptimizations);
      expect(CkPermission.accessMediaLocation.permission,
          Permission.accessMediaLocation);
      expect(CkPermission.activityRecognition.permission,
          Permission.activityRecognition);
      expect(CkPermission.manageExternalStorage.permission,
          Permission.manageExternalStorage);
      expect(CkPermission.systemAlertWindow.permission,
          Permission.systemAlertWindow);
      expect(CkPermission.requestInstallPackages.permission,
          Permission.requestInstallPackages);
      expect(CkPermission.appTrackingTransparency.permission,
          Permission.appTrackingTransparency);
      expect(CkPermission.criticalAlerts.permission, Permission.criticalAlerts);
      expect(CkPermission.accessNotificationPolicy.permission,
          Permission.accessNotificationPolicy);
      expect(CkPermission.scheduleExactAlarm.permission,
          Permission.scheduleExactAlarm);
      expect(CkPermission.backgroundRefresh.permission,
          Permission.backgroundRefresh);
      expect(CkPermission.assistant.permission, Permission.assistant);
    });

    test('equality and constructors', () {
      const p1 = CkPermission(Permission.camera);
      const p2 = CkPermission.from(Permission.camera);
      expect(p1, equals(p2));
      expect(p1, equals(CkPermission.camera));
      expect(p1.hashCode, equals(CkPermission.camera.hashCode));
      expect(p1.toString(), 'CkPermission(Camera)');
    });

    test('friendly permission names', () {
      expect(CkPermission.camera.name, 'Camera');
      expect(CkPermission.photos.name, 'Photos');
      expect(CkPermission.microphone.name, 'Microphone');
      expect(CkPermission.location.name, 'Location');
      expect(CkPermission.storage.name, 'Storage');
      expect(CkPermission.notification.name, 'Notifications');
      expect(CkPermission.contacts.name, 'Contacts');
      expect(CkPermission.sms.name, 'SMS');
      expect(CkPermission.phone.name, 'Phone');
      expect(CkPermission.calendar.name, 'Calendar');
      expect(CkPermission.reminders.name, 'Reminders');
      expect(CkPermission.sensors.name, 'Sensors');
      expect(CkPermission.speech.name, 'Speech Recognition');
      expect(CkPermission.bluetooth.name, 'Bluetooth');
      expect(CkPermission.mediaLibrary.name, 'Media Library');
      expect(CkPermission.audio.name, 'Audio');
      expect(CkPermission.videos.name, 'Videos');
      expect(CkPermission.appTrackingTransparency.name, 'App Tracking');
      expect(CkPermission.activityRecognition.name, 'Activity Recognition');
    });

    test('static getPermissionName helper', () {
      expect(CkPermission.getPermissionName(Permission.camera), 'Camera');
      expect(CkPermission.getPermissionName(Permission.photos), 'Photos');
    });

    test('extension methods on Permission', () {
      expect(Permission.camera.toCkPermission, equals(CkPermission.camera));
      expect(Permission.photos.toCkPermission, equals(CkPermission.photos));
    });

    test('CkPermissionHelperConfig default values', () {
      const config = CkPermissionHelperConfig();
      expect(config.permissionDenied, 'Permission Denied');
      expect(config.openSettings, 'Open Settings');
      expect(config.cancel, 'Cancel');
      expect(config.permissionIsPermanentlyDenied,
          'Permission is permanently denied.');
      expect(config.toFixThisPleaseGoTo, 'To fix this, please go to ');
      expect(config.andAllowThePermissionManually,
          'and allow the permission manually.');
    });
  });
}
