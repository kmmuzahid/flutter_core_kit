import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotPreview {
  ScreenshotPreview({
    required this.buildContext,
    required this.imagePath,
    this.duration = const Duration(seconds: 3),
    this.width = 120,
    this.height = 80,
    this.bottom = 20,
    this.left = 20,
    this.borderColor = Colors.white,
    this.borderRadius = 8,
    this.borderWidth = 2,
    BoxShadow? boxShadow,
  }) : boxShadow =
           boxShadow ??
           const BoxShadow(
             color: Colors.black45,
             blurRadius: 10,
             offset: Offset(0, 3),
           );
  final BuildContext buildContext;
  final String imagePath;
  final Duration duration;
  final double width;
  final double height;
  final double bottom;
  final double left;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final BoxShadow boxShadow;

  OverlayEntry? _overlayEntry;

  void show() {
    final overlay = Overlay.of(buildContext);

    _overlayEntry = OverlayEntry(
      builder:
          (_) => Positioned(
            bottom: bottom,
            left: left,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: borderWidth),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [boxShadow],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius - 2),
                  child: Image.file(
                    File(imagePath),
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_overlayEntry!);

    Future.delayed(duration).then((_) => hide());
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
