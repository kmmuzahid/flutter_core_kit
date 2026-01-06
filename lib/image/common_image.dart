import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kit/initizalizer.dart';
import 'package:core_kit/utils/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  void checkImageType() {}

  @override
  Widget build(BuildContext context) {
    try {
      if (src.isEmpty) return const SizedBox();

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
      return _buildErrorWidget();
    }
  }

  Widget getImage() {
    if (src.startsWith('assets/svg') || src.endsWith('.svg')) {
      return _buildSvgImage();
    } else if (src.startsWith('assets/')) {
      return _buildPngImage();
    } else if (src.startsWith('http') || src.startsWith('/image')) {
      return _buildNetworkImage();
    } else {
      return _buildFileImage();
    }
  }

  Widget _buildErrorWidget() {
    if (defaultImage == null) {
      return const SizedBox();
    }
    return Image.asset(defaultImage!);
  }

  Widget _buildNetworkImage() {
    final path = src.startsWith('http') ? src : '${CoreKit.instance.imageBaseUrl}$src';
    return CachedNetworkImage(
      height: size ?? height,
      width: size ?? width,
      imageUrl: path,
      fit: fill,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(image: imageProvider, fit: fill),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Skeletonizer(
          enabled: (downloadProgress.progress ?? 0) < 1,
          child: Container(color: Colors.white),
        );
      },
      errorWidget: (context, url, error) {
        AppLogger.error(error.toString(), tag: 'Common Image');

        return _buildErrorWidget();
      },
    );
  }

  Widget _buildSvgImage() {
    return SvgPicture.asset(
      src,
      colorFilter: imageColor != null ? ColorFilter.mode(imageColor!, BlendMode.srcIn) : null,
      height: size ?? height,
      width: size ?? width,
      fit: fill,
    );
  }

  Widget _buildFileImage() {
    return Image.file(
      File(src),
      color: imageColor,
      height: size ?? height,
      width: size ?? width,
      fit: fill,
    );
  }

  Widget _buildPngImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        src,
        color: imageColor,
        height: size ?? height,
        width: size ?? width,
        fit: fill,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.error(error.toString(), tag: 'Common Image');
          return _buildErrorWidget();
        },
      ),
    );
  }
}
