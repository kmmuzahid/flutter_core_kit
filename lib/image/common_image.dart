import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kit/core_kit.dart';
import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CommonImage extends StatelessWidget {
  const CommonImage({
    required this.src,
    this.imageColor,
    this.height,
    this.borderRadius = 0,
    this.width,
    this.size,
    this.fill = BoxFit.cover,
    this.defaultImage,
    this.enableGrayscale = false,
    super.key,
    this.borderRadiusCustom,
    this.enableAspectRatio = false,
  });
  final String src;
  final String? defaultImage;
  final Color? imageColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final double? size;
  final bool enableGrayscale;
  final BoxFit fill;
  final BorderRadius? borderRadiusCustom;
  final bool enableAspectRatio;

  BorderRadius getBorderRadius() {
    return borderRadiusCustom ?? BorderRadius.circular(borderRadius.r);
  }

  @override
  Widget build(BuildContext context) {
    if (enableAspectRatio && width != null && height != null && width! > 0 && height! > 0) {
      return AspectRatio(aspectRatio: (width ?? 0, height ?? 0).ar, child: _genralChild());
    }
    return _genralChild();
  }

  Widget _genralChild() {
    try {
      if (src.isEmpty) return placeholder();
    
      if (!enableGrayscale) return getImage();
    
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, // red
          0.2126, 0.7152, 0.0722, 0, 0, // green
          0.2126, 0.7152, 0.0722, 0, 0, // blue
          0, 0, 0, 1, 0, // alpha
        ]),
        child: getImage(),
      );
    } catch (e) {
      return ClipRRect(
        borderRadius: getBorderRadius(),
        child: _buildErrorWidget(),
      );
    }
  }

  Widget placeholder() {
    return ClipRRect(
      borderRadius: getBorderRadius(),
      child: SizedBox(
        height: size?.w ?? height?.w,
        width: size?.w ?? width?.w,
        child: Container(color: coreKitInstance.theme.colorScheme.outline),
      ),
    );
  }

  Widget getImage() {
    if ((src.startsWith('assets/svg') || src.endsWith('.svg')) &&
        src.startsWith('assets/')) {
      return _buildSvgImage();
    }

    // Local files (all known prefixes)
    const filePrefixes = [
      '/storage', // Android
      '/sdcard', // Android alias
      '/data/user', // Android app private
      '/data/data', // older Android private
      '/var', // iOS
      '/private/var', // older iOS
    ];

    if (src.startsWith('assets/') ||
        filePrefixes.any((prefix) => src.startsWith(prefix)) ||
        File(src).existsSync()) {
      return src.startsWith('assets/') ? _buildPngImage() : _buildFileImage();
    }

    return _buildNetworkImage();
  }

  Widget _buildErrorWidget() {
    if (defaultImage == null) {
      return const SizedBox();
    }
    return Image.asset(defaultImage!);
  }

  Widget _buildNetworkImage() {
    final path = src.startsWith('http')
        ? src
        : src.startsWith('/')
        ? '${coreKitInstance.imageBaseUrl}$src'
        : '${coreKitInstance.imageBaseUrl}/$src';
    return ClipRRect(
      borderRadius: getBorderRadius(),
      child: CachedNetworkImage(
        height: size?.w ?? height?.w,
        width: size?.w ?? width?.w,
        imageUrl: path,
        fit: fill,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: fill),
          ),
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Skeletonizer(
            enabled: (downloadProgress.progress ?? 0) < 1,
            child: placeholder(),
          );
        },
        errorWidget: (context, url, error) {
          AppLogger.error(error.toString(), tag: 'Common Image');

          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildSvgImage() {
    return ClipRRect(
      borderRadius: getBorderRadius(),
      child: SvgPicture.asset(
        src,
        colorFilter: imageColor != null
            ? ColorFilter.mode(imageColor!, BlendMode.srcIn)
            : null,
        height: size?.w ?? height?.w,
        width: size?.w ?? width?.w,
        fit: fill,
      ),
    );
  }

  Widget _buildFileImage() {
    return ClipRRect(
      borderRadius: getBorderRadius(),
      child: Image.file(
        File(src),
        color: imageColor,
        height: size?.w ?? height?.w,
        width: size?.w ?? width?.w,
        fit: fill,
      ),
    );
  }

  Widget _buildPngImage() {
    return ClipRRect(
      borderRadius: getBorderRadius(),
      child: Image.asset(
        src,
        color: imageColor,
        height: size?.w ?? height?.w,
        width: size?.w ?? width?.w,
        fit: fill,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.error(error.toString(), tag: 'Common Image');
          return _buildErrorWidget();
        },
      ),
    );
  }
}
