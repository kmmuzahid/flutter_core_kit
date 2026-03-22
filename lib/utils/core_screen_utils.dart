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
    if (width == null ||
        height == null ||
        device == null ||
        width == 0 ||
        height == 0) {
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
