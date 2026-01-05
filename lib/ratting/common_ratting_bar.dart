/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 17:53:20
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonRatingBar extends StatelessWidget {
  const CommonRatingBar({
    required this.rating,
    super.key,
    this.maxRating = 5,
    this.size = 24,
    this.color = Colors.amber,
    this.onRatingChanged,
    this.allowHalf = false,
    this.totalCount,
    this.textStyle,
    this.spacing = 4,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final ValueChanged<double>? onRatingChanged;
  final bool allowHalf;
  final int? totalCount;
  final TextStyle? textStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: spacing,
          children: List.generate(maxRating, (index) {
            final full = index + 1;
            final isHalf = allowHalf && (rating >= index + 0.5 && rating < full);
            final icon = rating >= full
                ? Icons.star
                : isHalf
                ? Icons.star_half
                : Icons.star_border;

            return GestureDetector(
              onTap: onRatingChanged == null
                  ? null
                  : () => onRatingChanged!(allowHalf ? index + 1.0 : full.toDouble()),
              child: Icon(icon, color: color, size: size.w),
            );
          }),
        ),
        if (totalCount != null) ...[
          const SizedBox(width: 6),
          Text(
            '($totalCount)',
            style: textStyle ?? TextStyle(fontSize: (size * 0.7).sp, color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }
}
