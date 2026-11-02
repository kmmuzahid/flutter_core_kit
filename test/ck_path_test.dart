import 'package:core_kit/utils/ck_path.dart';
import 'package:core_kit/utils/ck_path_web.dart' as web_path;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CkPath Tests', () {
    test('CkPath.join correctly joins paths', () {
      final path1 = CkPath.join('/var/data', 'cache');
      expect(path1, '/var/data/cache');

      final path2 = CkPath.join('/var/data/', '/cache/', 'temp');
      expect(path2, '/var/data/cache/temp');

      final path3 = CkPath.join('/app', 'files', 'voice', 'rec.m4a');
      expect(path3, '/app/files/voice/rec.m4a');
    });

    test('CkPath.join handles trailing and leading slashes gracefully', () {
      final joined = CkPath.join('folder///', '///subfolder///', 'file.txt');
      expect(joined, 'folder/subfolder/file.txt');
    });

    test(
      'ck_path_web returns fallback web directory stubs and paths',
      () async {
        expect(await web_path.getTempPath(), '/tmp');
        expect(await web_path.getDocumentsPath(), '/documents');
        expect(await web_path.getSupportPath(), '/support');
        expect(await web_path.getCachePath(), '/cache');
        expect(await web_path.getDownloadsPath(), '/downloads');
        expect(await web_path.getExternalStoragePath(), isNull);

        final tempDir = await web_path.getTemporaryDirectory();
        expect(tempDir.path, '/tmp');
        final docsDir = await web_path.getApplicationDocumentsDirectory();
        expect(docsDir.path, '/documents');

        await web_path.clearTemp(); // does not throw
      },
    );
  });
}
