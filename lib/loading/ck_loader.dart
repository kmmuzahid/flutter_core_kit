import 'package:core_kit/utils/ck_screen_utils.dart';
import 'package:flutter/material.dart';

class CkLoader extends StatelessWidget {
  const CkLoader({super.key, this.size = 60, this.strokeWidth = 4});

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

/// @deprecated Use [CkLoader] instead.
@Deprecated('Use CkLoader instead')
typedef CommonLoader = CkLoader;
