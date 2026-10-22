import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';

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
      ckError('Error sharing: $e');
    }
  }

  /// Resolves an image URL or path into a full valid URI string.
  ///
  /// Handles:
  /// - Full URLs with schemes (e.g. `http://...`, `https://...`)
  /// - Protocol-relative URLs (e.g. `//cdn.example.com/...`)
  /// - Full domains without scheme (e.g. `cdn.example.com/...`, `res.cloudinary.com/...`)
  /// - Relative paths with or without leading slashes (e.g. `/images/...`, `images/...`, `pic.jpg`)
  static String resolveImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    final lower = trimmed.toLowerCase();

    // 1. Full URL with scheme (http:// or https://)
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }

    // 2. Protocol-relative URL (//cdn.example.com/...)
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }

    // 3. Domain without scheme (e.g., cdn.example.com/image.jpg)
    final firstSlash = trimmed.indexOf('/');
    if (firstSlash > 0) {
      final host = trimmed.substring(0, firstSlash);
      final domainRegex = RegExp(
        r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(:\d+)?$',
      );
      final ipRegex = RegExp(
        r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)?$',
      );
      if (domainRegex.hasMatch(host) ||
          ipRegex.hasMatch(host) ||
          host.startsWith('localhost')) {
        return 'https://$trimmed';
      }
    }

    // 4. Relative path: combine with coreKitInstance.imageBaseUrl
    var baseUrl = '';
    try {
      baseUrl = coreKitInstance.imageBaseUrl.trim();
    } catch (_) {
      baseUrl = '';
    }

    if (baseUrl.isEmpty) {
      return trimmed;
    }

    var cleanBase = baseUrl;
    while (cleanBase.endsWith('/')) {
      cleanBase = cleanBase.substring(0, cleanBase.length - 1);
    }
    var cleanPath = trimmed;
    while (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return cleanBase.isEmpty ? cleanPath : '$cleanBase/$cleanPath';
  }

  Future<void> content({
    required String title,
    required String imageUrl,
    required String deepLinkUrl,
  }) async {
    try {
      final resolvedUrl = resolveImageUrl(imageUrl);
      final uri = Uri.tryParse(resolvedUrl);
      if (uri == null) {
        ckError('Invalid image URL: $imageUrl');
        return;
      }

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        ckError('Failed to fetch image ($uri): status ${response.statusCode}');
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
      ckError('Error sharing: $e');
    }
  }

  /// Creates a [CkShareButton] wrapping a [child] with an adaptive edge-tracing loader.
  static Widget button({
    Key? key,
    required String title,
    required String deepLinkUrl,
    String? imageUrl,
    ByteData? byteImage,
    required Widget child,
    CkShareLoaderStyle loaderStyle = CkShareLoaderStyle.adaptiveEdge,
    BoxShape? shape,
    BorderRadius? borderRadius,
    double strokeWidth = 2.5,
    double strokeLengthFactor = 0.3,
    Color? loaderColor,
    Color? trackColor,
    double paddingOffset = 0.0,
    Duration animationDuration = const Duration(milliseconds: 1100),
    Widget? customLoader,
    VoidCallback? onTap,
    VoidCallback? onShareStart,
    VoidCallback? onShareSuccess,
    void Function(Object error)? onShareError,
  }) =>
      CkShareButton(
        key: key,
        title: title,
        deepLinkUrl: deepLinkUrl,
        imageUrl: imageUrl,
        byteImage: byteImage,
        loaderStyle: loaderStyle,
        shape: shape,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
        strokeLengthFactor: strokeLengthFactor,
        loaderColor: loaderColor,
        trackColor: trackColor,
        paddingOffset: paddingOffset,
        animationDuration: animationDuration,
        customLoader: customLoader,
        onTap: onTap,
        onShareStart: onShareStart,
        onShareSuccess: onShareSuccess,
        onShareError: onShareError,
        child: child,
      );

  /// Creates a [CkShareButton] using a [builder] callback for full custom control.
  static Widget builder({
    Key? key,
    required String title,
    required String deepLinkUrl,
    String? imageUrl,
    ByteData? byteImage,
    required Widget Function(
      BuildContext context,
      Future<void> Function() share,
      bool isLoading,
    ) builder,
    VoidCallback? onShareStart,
    VoidCallback? onShareSuccess,
    void Function(Object error)? onShareError,
  }) =>
      CkShareButton.builder(
        key: key,
        title: title,
        deepLinkUrl: deepLinkUrl,
        imageUrl: imageUrl,
        byteImage: byteImage,
        builder: builder,
        onShareStart: onShareStart,
        onShareSuccess: onShareSuccess,
        onShareError: onShareError,
      );
}

