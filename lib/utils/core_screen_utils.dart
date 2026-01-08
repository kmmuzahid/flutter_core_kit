/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:39:59
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

class CoreScreenUtils {
  CoreScreenUtils._();

  static late Size deviceSize;
  static late double _designWidth;
  static late double _designHeight;

  static void init(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    _designWidth = CoreKit.instance.designSize.width;
    _designHeight = CoreKit.instance.designSize.height;
  }

  static double _scale() {
    return deviceSize.width / _designWidth < deviceSize.height / _designHeight
        ? deviceSize.width / _designWidth
        : deviceSize.height / _designHeight;
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
