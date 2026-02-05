/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:21:15
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.title,
    this.onBackPress,
    this.titleWidget,
    this.leading,
    this.actions,
    this.isCenterTitle = true,
    this.backgroundColor,
    this.hideBack = false,
    this.disableBack = false,
    this.linearGradientBackground,
    this.height,
    this.titleAlignment = Alignment.center,
    this.bottomLeftRadius = 0,
    this.bottomRightRadius = 0,
    this.iconColor,
    this.titleColor,
    this.leadingAlignment = Alignment.center,
  });
  
  final String? title;
  final Widget? titleWidget;
  final Function()? onBackPress;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isCenterTitle;
  final Color? backgroundColor;
  final bool hideBack;
  final bool disableBack;
  final LinearGradient? linearGradientBackground;
  final double? height;
  final AlignmentGeometry? titleAlignment;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final Color? iconColor;
  final Color? titleColor;
  final AlignmentGeometry leadingAlignment;

  @override
  Size get preferredSize => Size.fromHeight(height?.h ?? kToolbarHeight.h);

  @override
  Widget build(BuildContext context) {
    // Determine the effective background color
    final effectiveBackgroundColor = backgroundColor ?? CoreKit.instance.backgroundColor;

    // Calculate contrast color for icons and text
    final contrastColor = _getContrastColor(effectiveBackgroundColor);

    // Calculate leading width
    final leadingWidth = hideBack ? 0.0 : 56.0.w;

    // Calculate actions width (approximate)
    final actionsWidth = (actions?.length ?? 0) * 56.0.w;

    final appBar = AppBar(
      backgroundColor: linearGradientBackground != null
          ? Colors.transparent
          : effectiveBackgroundColor,
      centerTitle: titleAlignment == null ? isCenterTitle : false,
      toolbarHeight: height ?? kToolbarHeight,

      // Set icon theme for leading and actions
      iconTheme: IconThemeData(color: iconColor ?? contrastColor),
      actionsIconTheme: IconThemeData(color: iconColor ?? contrastColor),

      leadingWidth: leadingWidth,

      leading: hideBack
          ? SizedBox.shrink()
          : SafeArea(
              child: Container(
                alignment: leadingAlignment,
                padding: EdgeInsets.only(left: 10.0.w),
                child: GestureDetector(
                  onTap: () {
                    if (onBackPress != null) {
                      onBackPress!();
                    }
                    if (!disableBack) {
                      CoreKit.instance.back();
                    }
                  },
                  child:
                      leading ??
                      (CoreKit.instance.backButton == null
                          ? Icon(
                              CoreKit.instance.backIcon.icon,
                              size: CoreKit.instance.backIcon.size ?? 25.w,
                              color: iconColor ?? contrastColor,
                            )
                          : CoreKit.instance.backButton!),
                ),
              ),
          ),
      actions: actions ?? _appBarActions(),

      // Use title only when no custom alignment is needed
      title: titleAlignment == null
          ? (titleWidget ??
                CommonText(
                  text: title ?? '',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  textColor: titleColor ?? contrastColor,
                ))
          : null,

      flexibleSpace: Container(
        decoration: linearGradientBackground != null
            ? BoxDecoration(gradient: linearGradientBackground)
            : null,
        child: titleAlignment != null
            ? SafeArea(
                child: Align(
                  alignment: titleAlignment!,
                  child:
                      titleWidget ??
                      CommonText(
                        text: title ?? '',
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        textColor: titleColor ?? contrastColor,
                      ),
                ),
              )
            : linearGradientBackground != null
            ? const SizedBox.shrink()
            : null,
      ),
    );

    // Apply bottom border radius if specified
    if (bottomLeftRadius > 0 || bottomRightRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomLeftRadius),
          bottomRight: Radius.circular(bottomRightRadius),
        ),
        child: appBar,
      );
    }

    return appBar;
  }

  /// Calculate contrast color based on background brightness
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();

    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.7 ? Colors.black : Colors.white;
  }

  List<Widget> _appBarActions() => [];
}
