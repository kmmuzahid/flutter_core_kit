/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:21:15
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

class AppbarConfig {
  /// ()=> Get.back() or Navigator.pop(context) etc
  final Function()? onBack;
  Function()? get getBack => onBack;

  /// Default back icon
  final Icon backIcon;

  /// Custom back button. If null, backIcon will be used
  final Widget? backButton;

  /// Custom decoration. If null, default background color will be used
  final BoxDecoration? decoration;

  /// Custom background color. If null, default background color will be used
  final Color? backgroundColor;

  /// Custom height. If null, default height will be used
  final double? height;

  /// Custom icon color. If null, default icon color will be used
  final Color? iconColor;

  /// Custom title color
  final Color? titleColor;

  AppbarConfig({
    this.onBack,
    this.backIcon = const Icon(Icons.arrow_back_ios, size: 25),
    this.backButton,
    this.decoration,
    this.backgroundColor,
    this.height,
    this.iconColor,
    this.titleColor,
  });

  AppbarConfig copyWith({
    Function()? onBack,
    Icon? backIcon,
    Widget? backButton,
    BoxDecoration? decoration,
    Color? backgroundColor,
    double? height,
    Color? iconColor,
    Color? titleColor,
  }) {
    return AppbarConfig(
      onBack: onBack ?? this.onBack,
      backIcon: backIcon ?? this.backIcon,
      backButton: backButton ?? this.backButton,
      decoration: decoration ?? this.decoration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      iconColor: iconColor ?? this.iconColor,
      titleColor: titleColor ?? this.titleColor,
    );
  }
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.title,
    this.onBackPress,
    this.titleWidget,
    this.leading,
    this.actions,
    this.isCenterTitle = true,
    this.hideBack = false,
    this.disableBack = false,
    this.titleAlignment = Alignment.center,
    // this.bottomLeftRadius = 0,
    // this.bottomRightRadius = 0,
    this.leadingAlignment = Alignment.center,
    this.appbarConfig,
  });

  final String? title;
  final Widget? titleWidget;
  final Function()? onBackPress;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isCenterTitle;
  final bool hideBack;
  final bool disableBack;
  final AlignmentGeometry? titleAlignment;
  // final double bottomLeftRadius;
  // final double bottomRightRadius;

  final AlignmentGeometry leadingAlignment;
  final AppbarConfig? appbarConfig;

  @override
  Size get preferredSize => Size.fromHeight(
    (appbarConfig?.height?.h ?? CoreKit.instance.appbarConfig.height?.h) ?? kToolbarHeight.h,
  );

  @override
  Widget build(BuildContext context) {
    // Determine the effective background color

    AppbarConfig config = AppbarConfig(
      onBack: appbarConfig?.onBack ?? CoreKit.instance.appbarConfig.getBack,
      backIcon: appbarConfig?.backIcon ?? CoreKit.instance.appbarConfig.backIcon,
      backButton: appbarConfig?.backButton ?? CoreKit.instance.appbarConfig.backButton,
      decoration: (appbarConfig?.backgroundColor != null && appbarConfig?.decoration == null)
          ? null
          : appbarConfig?.decoration ?? CoreKit.instance.appbarConfig.decoration,
      backgroundColor:
          appbarConfig?.backgroundColor ?? CoreKit.instance.appbarConfig.backgroundColor,
      height: appbarConfig?.height ?? CoreKit.instance.appbarConfig.height,
      iconColor: appbarConfig?.iconColor ?? CoreKit.instance.appbarConfig.iconColor,
      titleColor: appbarConfig?.titleColor ?? CoreKit.instance.appbarConfig.titleColor,
    );

    final effectiveBackgroundColor = config.backgroundColor ?? CoreKit.instance.backgroundColor;

    // Calculate contrast color for icons and text
    final contrastColor = _getContrastColor(effectiveBackgroundColor);

    // Calculate leading width
    final leadingWidth = hideBack ? 0.0 : 56.0.w;

    final appBar = AppBar(
      backgroundColor: config.decoration != null ? Colors.transparent : effectiveBackgroundColor,
      centerTitle: titleAlignment == null ? isCenterTitle : false,
      toolbarHeight: config.height?.h ?? kToolbarHeight,

      // Set icon theme for leading and actions
      iconTheme: IconThemeData(color: config.iconColor ?? contrastColor),
      actionsIconTheme: IconThemeData(color: config.iconColor ?? contrastColor),

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
                      config.getBack?.call();
                    }
                  },
                  child:
                      leading ??
                      (config.backButton == null
                          ? Icon(
                              config.backIcon.icon,
                              size: config.backIcon.size ?? 25.w,
                              color: config.iconColor ?? contrastColor,
                            )
                          : config.backButton!),
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
                  textColor: config.titleColor ?? contrastColor,
                ))
          : null,

      flexibleSpace: Container(
        decoration: config.decoration,
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
                        textColor: config.titleColor ?? contrastColor,
                      ),
                ),
              )
            : config.decoration != null
            ? const SizedBox.shrink()
            : null,
      ),
    );

    // Apply bottom border radius if specified
    // if (bottomLeftRadius > 0 || bottomRightRadius > 0) {
    //   return ClipRRect(
    //     borderRadius: BorderRadius.only(
    //       bottomLeft: Radius.circular(bottomLeftRadius),
    //       bottomRight: Radius.circular(bottomRightRadius),
    //     ),
    //     child: appBar,
    //   );
    // }

    return appBar;
  }

  /// Calculate contrast color based on background brightness
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.96 ? Colors.black : Colors.white;
  }

  List<Widget> _appBarActions() => [];
}
