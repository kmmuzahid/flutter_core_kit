import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:universal_io/io.dart';

Future<Directory> getTemporaryDirectory() => pp.getTemporaryDirectory();

Future<Directory> getApplicationDocumentsDirectory() =>
    pp.getApplicationDocumentsDirectory();

Future<Directory> getApplicationSupportDirectory() =>
    pp.getApplicationSupportDirectory();

Future<Directory> getApplicationCacheDirectory() =>
    pp.getApplicationCacheDirectory();

Future<Directory?> getDownloadsDirectory() => pp.getDownloadsDirectory();

Future<Directory?> getExternalStorageDirectory() =>
    pp.getExternalStorageDirectory();

Future<List<Directory>?> getExternalCacheDirectories() =>
    pp.getExternalCacheDirectories();

Future<List<Directory>?> getExternalStorageDirectories({dynamic type}) {
  if (type is pp.StorageDirectory) {
    return pp.getExternalStorageDirectories(type: type);
  }
  return pp.getExternalStorageDirectories();
}

Future<String> getTempPath() async => (await pp.getTemporaryDirectory()).path;

Future<String> getDocumentsPath() async =>
    (await pp.getApplicationDocumentsDirectory()).path;

Future<String> getSupportPath() async =>
    (await pp.getApplicationSupportDirectory()).path;

Future<String> getCachePath() async =>
    (await pp.getApplicationCacheDirectory()).path;

Future<String?> getDownloadsPath() async =>
    (await pp.getDownloadsDirectory())?.path;

Future<String?> getExternalStoragePath() async =>
    (await pp.getExternalStorageDirectory())?.path;

Future<void> clearTemp() async {
  try {
    final dir = await pp.getTemporaryDirectory();
    if (dir.existsSync()) {
      final entities = dir.listSync();
      for (final entity in entities) {
        try {
          await entity.delete(recursive: true);
        } catch (e) {
          debugPrint(
            'Failed to delete temp entity: ${entity.path}, error: $e',
          );
        }
      }
    }
  } catch (e) {
    debugPrint('Error clearing temp directory: $e');
  }
}
