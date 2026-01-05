/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 17:53:21
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  const CommonLoader({super.key, this.size = 60, this.strokeWidth = 4});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size.w,
        width: size.w,
        child: CircularProgressIndicator.adaptive(strokeWidth: strokeWidth.w),
      ),
    );
  }
}
