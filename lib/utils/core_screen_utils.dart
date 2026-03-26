/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:39:59
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

class CoreScreenUtils {
  CoreScreenUtils._();

  static Size? _deviceSize;
  static double? _designWidth;
  static double? _designHeight;

  static Size get deviceSize => _deviceSize ?? coreKitInstance.designSize;

  static void init(BuildContext context, VoidCallback onComplete) {
    _deviceSize = MediaQuery.of(context).size;
    _designWidth = coreKitInstance.designSize.width;
    _designHeight = coreKitInstance.designSize.height;
    onComplete();
  }

  static double _scale() {
    final width = _designWidth;
    final height = _designHeight;
    final device = _deviceSize;
    if (width == null || height == null || device == null || width == 0 || height == 0) {
      return 1.0;
    }
    return device.width / width < device.height / height
        ? device.width / width
        : device.height / height;
  }

  static double width({required num value}) => value * _scale();
  static double height({required num value}) => value * _scale();
  static double radius({required num value}) => value * _scale();
  static double sp({required num value}) => value * _scale();
}

// ---------------------------------------------------------------------------
// Gap helpers
// ---------------------------------------------------------------------------

extension GapExtesntion on int {
  Widget get width => SizedBox(width: toDouble());
  Widget get height => SizedBox(height: toDouble());
}

// ---------------------------------------------------------------------------
// Responsive extensions – int
// ---------------------------------------------------------------------------

extension responsive on int {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

// ---------------------------------------------------------------------------
// Responsive extensions – double
// ---------------------------------------------------------------------------

extension responsiveDouble on double {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

// ---------------------------------------------------------------------------
// Aspect ratio extensions
// ---------------------------------------------------------------------------

extension AspectRatioExtension on Size {
  /// Wraps a placeholder in a width-constrained [AspectRatio] using this
  /// [Size] as the Figma widget dimensions.
  ///
  /// Prefer using [WidgetAspectRatio.toAr] on a real widget, or the record
  /// extension `(207, 232).ar` directly inside [AspectRatio.aspectRatio].
  ///
  /// Raw ratio (no SizedBox) — useful when you only need the double:
  /// ```dart
  /// AspectRatio(aspectRatio: Size(207, 232).arValue, child: MyCard())
  /// ```
  double get arValue {
    assert(height != 0, 'Size.height must not be zero');

    final designW = CoreScreenUtils._designWidth;
    final designH = CoreScreenUtils._designHeight;
    final device = CoreScreenUtils._deviceSize;

    if (designW == null ||
        designH == null ||
        device == null ||
        designW == 0 ||
        designH == 0 ||
        height == 0) {
      return width / height;
    }

    final scale = device.width / designW < device.height / designH
        ? device.width / designW
        : device.height / designH;

    return (width * scale) / (height * scale);
  }
}

extension AspectRatioRecord on (num width, num height) {
  /// Raw aspect ratio double — use inside [AspectRatio.aspectRatio].
  /// ```dart
  /// AspectRatio(aspectRatio: (207, 232).arValue, child: MyCard())
  /// ```
  double get arValue => Size($1.toDouble(), $2.toDouble()).arValue;
}

extension WidgetAspectRatio on Widget {
  /// Constrains the widget to a responsive width and derives its height
  /// automatically via [AspectRatio] — no [SizedBox] needed at the call site.
  ///
  /// ```dart
  /// MyCard().toAr(207, 232)
  /// ```
  Widget toAr(num width, num height) => SizedBox(
    width: width.toDouble().w,
    child: AspectRatio(aspectRatio: (width, height).arValue, child: this),
  );
}
