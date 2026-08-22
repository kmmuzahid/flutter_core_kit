import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:universal_io/io.dart';

/// A utility class for accessing standard device directories and file paths.
///
/// Easily retrieve temporary, documents, cache, downloads, and support directories:
/// ```dart
/// // Get Directory instances
/// final tempDir = await CkPath.getTemporaryDirectory();
/// final docDir = await CkPath.getApplicationDocumentsDirectory();
///
/// // Get String paths directly
/// final tempPath = await CkPath.tempPath;
/// final docsPath = await CkPath.documentsPath;
///
/// // Create a temporary file (ideal for audio recording, camera captures, caching)
/// final voiceFile = await CkPath.createTempFile(
///   prefix: 'rec_',
///   extension: 'm4a',
/// );
/// ```
abstract class CkPath {
  CkPath._();

  // ---------------------------------------------------------------------------
  // Directory Getters
  // ---------------------------------------------------------------------------

  /// Path to the directory where any newly created files may be allocated to
  /// the system temporary folder.
  static Future<Directory> getTemporaryDirectory() =>
      pp.getTemporaryDirectory();

  /// Alias for [getTemporaryDirectory].
  static Future<Directory> get tempDir => pp.getTemporaryDirectory();

  /// Alias for [getTemporaryDirectory].
  static Future<Directory> get temporaryDirectory => pp.getTemporaryDirectory();

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  static Future<Directory> getApplicationDocumentsDirectory() =>
      pp.getApplicationDocumentsDirectory();

  /// Alias for [getApplicationDocumentsDirectory].
  static Future<Directory> get documentsDir =>
      pp.getApplicationDocumentsDirectory();

  /// Alias for [getApplicationDocumentsDirectory].
  static Future<Directory> get documentsDirectory =>
      pp.getApplicationDocumentsDirectory();

  /// Alias for [getApplicationDocumentsDirectory].
  static Future<Directory> get docsDir => pp.getApplicationDocumentsDirectory();

  /// Path to a directory where the application may place application support
  /// files.
  static Future<Directory> getApplicationSupportDirectory() =>
      pp.getApplicationSupportDirectory();

  /// Alias for [getApplicationSupportDirectory].
  static Future<Directory> get supportDir =>
      pp.getApplicationSupportDirectory();

  /// Alias for [getApplicationSupportDirectory].
  static Future<Directory> get supportDirectory =>
      pp.getApplicationSupportDirectory();

  /// Path to the directory where application specific cache files can be stored.
  static Future<Directory> getApplicationCacheDirectory() =>
      pp.getApplicationCacheDirectory();

  /// Alias for [getApplicationCacheDirectory].
  static Future<Directory> get cacheDir => pp.getApplicationCacheDirectory();

  /// Alias for [getApplicationCacheDirectory].
  static Future<Directory> get cacheDirectory =>
      pp.getApplicationCacheDirectory();

  /// Path to the directory where downloaded files are stored.
  /// Supported on Android, iOS, macOS, Windows, Linux.
  static Future<Directory?> getDownloadsDirectory() =>
      pp.getDownloadsDirectory();

  /// Alias for [getDownloadsDirectory].
  static Future<Directory?> get downloadsDir => pp.getDownloadsDirectory();

  /// Alias for [getDownloadsDirectory].
  static Future<Directory?> get downloadsDirectory =>
      pp.getDownloadsDirectory();

  /// Path to the primary external storage directory (Android only).
  static Future<Directory?> getExternalStorageDirectory() =>
      pp.getExternalStorageDirectory();

  /// Alias for [getExternalStorageDirectory].
  static Future<Directory?> get externalStorageDir =>
      pp.getExternalStorageDirectory();

  /// Paths to directories where application specific external cache data can be stored (Android only).
  static Future<List<Directory>?> getExternalCacheDirectories() =>
      pp.getExternalCacheDirectories();

  /// Paths to directories where application specific data can be stored (Android only).
  static Future<List<Directory>?> getExternalStorageDirectories({
    pp.StorageDirectory? type,
  }) => pp.getExternalStorageDirectories(type: type);

  // ---------------------------------------------------------------------------
  // String Path Getters
  // ---------------------------------------------------------------------------

  /// Returns the absolute path string of the temporary directory.
  static Future<String> get tempPath async =>
      (await pp.getTemporaryDirectory()).path;

  /// Returns the absolute path string of the application documents directory.
  static Future<String> get documentsPath async =>
      (await pp.getApplicationDocumentsDirectory()).path;

  /// Alias for [documentsPath].
  static Future<String> get docsPath async => documentsPath;

  /// Returns the absolute path string of the application support directory.
  static Future<String> get supportPath async =>
      (await pp.getApplicationSupportDirectory()).path;

  /// Returns the absolute path string of the application cache directory.
  static Future<String> get cachePath async =>
      (await pp.getApplicationCacheDirectory()).path;

  /// Returns the absolute path string of the downloads directory, or `null` if not available.
  static Future<String?> get downloadsPath async =>
      (await pp.getDownloadsDirectory())?.path;

  /// Returns the absolute path string of external storage, or `null` if not available.
  static Future<String?> get externalStoragePath async =>
      (await pp.getExternalStorageDirectory())?.path;

  // ---------------------------------------------------------------------------
  // File Path & Creation Helpers
  // ---------------------------------------------------------------------------

  /// Generates a full file path inside the temporary directory.
  ///
  /// Example:
  /// ```dart
  /// // Produces "/.../temp/rec_1723368291000.m4a"
  /// final path = await CkPath.getTempFilePath(
  ///   prefix: 'rec_',
  ///   extension: 'm4a',
  /// );
  /// ```
  static Future<String> getTempFilePath({
    String? fileName,
    String? prefix,
    String? extension,
  }) async {
    final temp = await tempPath;
    final name = _resolveFileName(
      fileName: fileName,
      prefix: prefix,
      extension: extension,
    );
    return join(temp, name);
  }

  /// Generates a full file path inside the application documents directory.
  static Future<String> getDocumentFilePath(String fileName) async {
    final docs = await documentsPath;
    return join(docs, fileName);
  }

  /// Generates a full file path inside the application cache directory.
  static Future<String> getCacheFilePath(String fileName) async {
    final cache = await cachePath;
    return join(cache, fileName);
  }

  /// Creates and returns a [File] inside the temporary directory.
  ///
  /// Perfect for voice recordings, camera frames, temporary exports, etc.
  static Future<File> createTempFile({
    String? fileName,
    String? prefix,
    String? extension,
  }) async {
    final filePath = await getTempFilePath(
      fileName: fileName,
      prefix: prefix,
      extension: extension,
    );
    final file = File(filePath);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Creates and returns a [File] inside the application documents directory.
  static Future<File> createDocumentFile(String fileName) async {
    final filePath = await getDocumentFilePath(fileName);
    final file = File(filePath);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Joins path parts using the appropriate platform separator.
  static String join(
    String part1,
    String part2, [
    String? part3,
    String? part4,
    String? part5,
  ]) {
    final separator = Platform.isWindows ? r'\' : '/';

    String trimPart(String p) {
      var s = p;
      while (s.startsWith('/') || s.startsWith(r'\')) {
        s = s.substring(1);
      }
      while (s.endsWith('/') || s.endsWith(r'\')) {
        s = s.substring(0, s.length - 1);
      }
      return s;
    }

    var base = part1;
    while (base.length > 1 && (base.endsWith('/') || base.endsWith(r'\'))) {
      base = base.substring(0, base.length - 1);
    }

    final parts = [part2, part3, part4, part5].whereType<String>();
    for (final part in parts) {
      final trimmed = trimPart(part);
      if (trimmed.isNotEmpty) {
        if (base.isEmpty) {
          base = trimmed;
        } else if (base.endsWith(separator)) {
          base = '$base$trimmed';
        } else {
          base = '$base$separator$trimmed';
        }
      }
    }
    return base;
  }

  /// Deletes all files within the temporary directory without deleting the directory itself.
  static Future<void> clearTemp() async {
    try {
      final dir = await getTemporaryDirectory();
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

  static String _resolveFileName({
    String? fileName,
    String? prefix,
    String? extension,
  }) {
    if (fileName != null && fileName.isNotEmpty) {
      return fileName;
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final p = prefix ?? '';
    final ext = (extension != null && extension.isNotEmpty)
        ? (extension.startsWith('.') ? extension : '.$extension')
        : '';
    return '$p$timestamp$ext';
  }
}
