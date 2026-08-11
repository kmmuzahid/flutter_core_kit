import 'package:core_kit/utils/ck_path.dart';
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
  });
}
