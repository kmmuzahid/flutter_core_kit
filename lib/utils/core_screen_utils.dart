/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:39:59
 * @Email: km.muzahid@gmail.com
 */
import 'package:flutter/material.dart';

class CoreScreenUtils {
  CoreScreenUtils._();

  static late Size size;

  static late double _designWidth;
  static late double _designHeight;

  static void init(BuildContext context, {double width = 375, double height = 882}) {
    _designWidth = width;
    _designHeight = height;
    size = MediaQuery.of(context).size;
  }

  static double width({required num value}) {
    final scaleWidth = size.width / _designWidth;
    return value * scaleWidth;
  }

  static double height({required num value}) {
    final scaleHeight = size.height / _designHeight;
    return value * scaleHeight;
  }

  static double radius({required num value}) {
    final scaleWidth = size.width / _designWidth;
    final scaleHeight = size.height / _designHeight;
    return value * (scaleWidth < scaleHeight ? scaleWidth : scaleHeight);
  }

  static double sp({required num value}) {
    final scaleWidth = size.width / _designWidth;
    final scaleHeight = size.height / _designHeight;
    return value * (scaleWidth < scaleHeight ? scaleWidth : scaleHeight);
  }
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
