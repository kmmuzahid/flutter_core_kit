import 'package:universal_io/io.dart';

Future<Directory> getTemporaryDirectory() async => Directory('/tmp');

Future<Directory> getApplicationDocumentsDirectory() async =>
    Directory('/documents');

Future<Directory> getApplicationSupportDirectory() async =>
    Directory('/support');

Future<Directory> getApplicationCacheDirectory() async => Directory('/cache');

Future<Directory?> getDownloadsDirectory() async => Directory('/downloads');

Future<Directory?> getExternalStorageDirectory() async => null;

Future<List<Directory>?> getExternalCacheDirectories() async => null;

Future<List<Directory>?> getExternalStorageDirectories({dynamic type}) async =>
    null;

Future<String> getTempPath() async => '/tmp';

Future<String> getDocumentsPath() async => '/documents';

Future<String> getSupportPath() async => '/support';

Future<String> getCachePath() async => '/cache';

Future<String?> getDownloadsPath() async => '/downloads';

Future<String?> getExternalStoragePath() async => null;

Future<void> clearTemp() async {}
