import 'dart:io';

import 'package:core_kit/initializer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CommonShare {
  CommonShare._();
  static final CommonShare instance = CommonShare._();

  Future<void> shareByteContent({
    required String title,
    required ByteData imageUrl, // <-- URL instead of asset
    required String deepLinkUrl,
  }) async {
    try {
      // Save to temporary folder
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(imageUrl.buffer.asUint8List());
      final xFile = XFile(file.path);
      final params = ShareParams(
        text: '$title\n$deepLinkUrl',
        files: [xFile],
        title: title,
        previewThumbnail: xFile,
      );
      await SharePlus.instance.share(params);

      file.delete();
    } catch (e) {
      print("Error sharing: $e");
    }
  }

  Future<void> shareContent({
    required String title,
    required String imageUrl, // <-- URL instead of asset
    required String deepLinkUrl,
  }) async {
    try {
      // Download the image
      final response = await http.get(Uri.parse('${CoreKit.instance.imageBaseUrl}$imageUrl'));
      if (response.statusCode != 200) {
        return;
      }

      // Save to temporary folder
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      final xFile = XFile(file.path);
      final params = ShareParams(
        text: '$title\n$deepLinkUrl',
        files: [xFile],
        title: title,
        previewThumbnail: xFile,
      );
      await SharePlus.instance.share(params);

      file.delete();
    } catch (e) {
      print("Error sharing: $e");
    }
  }

  // flutter_redirectly 2.1.2
}
