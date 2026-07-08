import 'dart:io';

import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CkShare {
  CkShare._();
  static final CkShare instance = CkShare._();

  Future<void> byteContent({
    required String title,
    required ByteData imageUrl,
    required String deepLinkUrl,
  }) async {
    try {
      final sanitizedTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$sanitizedTitle.jpg');
      await file.writeAsBytes(imageUrl.buffer.asUint8List());
      final xFile = XFile(file.path);
      final params = ShareParams(
        text: '$title\n$deepLinkUrl',
        files: [xFile],
        title: title,
        subject: title,
        fileNameOverrides: ['$sanitizedTitle.jpg'],
        previewThumbnail: xFile,
      );
      await SharePlus.instance.share(params);
      file.delete();
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  Future<void> content({
    required String title,
    required String imageUrl,
    required String deepLinkUrl,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${coreKitInstance.imageBaseUrl}$imageUrl'),
      );
      if (response.statusCode != 200) {
        return;
      }

      final sanitizedTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$sanitizedTitle.jpg');
      await file.writeAsBytes(response.bodyBytes);
      final xFile = XFile(file.path);
      final params = ShareParams(
        text: '$title\n$deepLinkUrl',
        files: [xFile],
        title: title,
        subject: title,
        fileNameOverrides: ['$sanitizedTitle.jpg'],
        previewThumbnail: xFile,
      );
      await SharePlus.instance.share(params);
      file.delete();
    } catch (e) {
      print('Error sharing: $e');
    }
  }
}

