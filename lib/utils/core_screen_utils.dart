import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
 
class CoreScreenUtils {
  CoreScreenUtils._();

  static Size? _deviceSize;
  static double? _designWidth;
  static double? _designHeight;
 
  static Size get deviceSize => _deviceSize ?? coreKitInstance.designSize;
 
  static void init(BuildContext context, VoidCallback? onComplete) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deviceSize = MediaQuery.of(context).size;
      _designWidth = coreKitInstance.designSize.width;
      _designHeight = coreKitInstance.designSize.height;
 
      onComplete?.call();
    });
  }

  static double _scale() {
    final width = _designWidth;
    final height = _designHeight;
    final device = _deviceSize;

    if (width == null || height == null || device == null || width == 0 || height == 0) {
      return 1.0;
    }

    final value = device.width / width < device.height / height
        ? device.width / width
        : device.height / height;
    return value > 0 ? value : 1.0;
  }

  static double width({required num value}) => value * _scale();
  static double height({required num value}) => value * _scale();
  static double radius({required num value}) => value * _scale();
  static double sp({required num value}) => value * _scale();
}


extension GapExtesntion on int {
  Widget get width => SizedBox(width: toDouble());
  Widget get height => SizedBox(height: toDouble());
}
 
extension responsive on int {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

extension responsiveDouble on double {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

 
extension AspectRatioExtension on Size {
  double get arValue {
    final designW = CoreScreenUtils._designWidth;
    final designH = CoreScreenUtils._designHeight;
    final device = CoreScreenUtils._deviceSize;

    if (designW == null ||
        designH == null ||
        device == null ||
        designW == 0 ||
        designH == 0 ||
        height == 0) {
      return 1.0; 
    }

    final scale = device.width / designW < device.height / designH
        ? device.width / designW
        : device.height / designH;

    final value = (width * scale) / (height * scale);
    return value > 0 ? value : 1.0;
  }
}

extension AspectRatioRecord on (num width, num height) {
  double get arValue => Size($1.toDouble(), $2.toDouble()).arValue;
}

extension WidgetAspectRatio on Widget {
  Widget toAr(num width, num height) => SizedBox(
    width: width.toDouble().w,
    child: AspectRatio(aspectRatio: (width, height).arValue, child: this),
  );
}
