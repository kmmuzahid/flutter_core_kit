/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:21:15
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AppbarConfig {
  /// ()=> Get.back() or Navigator.pop(context) etc
  final Function()? onBack;
  Function()? get getBack => onBack;

  /// Default back icon
  final Icon backIcon;

  /// Custom back button. If null, backIcon will be used
  final Widget? backButton;

  /// Custom decoration. If null, default background color will be used
  final BoxDecoration Function()? decoration;

  /// Custom background color. If null, default background color will be used
  final Color? backgroundColor;

  /// Custom height. If null, default height will be used
  final double? height;

  /// Custom icon color. If null, default icon color will be used
  final Color Function()? iconColor;

  /// Custom title color
  final Color Function()? titleColor;

  final List<Widget>? actions;

  final AlignmentGeometry? titleAlignment;

  final AlignmentGeometry? leadingAlignment;

  final AlignmentGeometry? actionAlignment;

  final double titleSpacing;

  final EdgeInsets leadingPadding;

  AppbarConfig({
    this.onBack,
    this.backIcon = const Icon(Icons.arrow_back_ios, size: 25),
    this.backButton,
    this.decoration,
    this.backgroundColor,
    this.height,
    this.iconColor,
    this.titleColor,
    this.actions,
    this.titleAlignment,
    this.leadingAlignment,
    this.actionAlignment,
    this.titleSpacing = 0,
    this.leadingPadding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  AppbarConfig copyWith({
    Function()? onBack,
    Icon? backIcon,
    Widget? backButton,
    BoxDecoration Function()? decoration,
    Color? backgroundColor,
    double? height,
    Color Function()? iconColor,
    Color Function()? titleColor,
    List<Widget>? actions,
    AlignmentGeometry? titleAlignment,
    AlignmentGeometry? leadingAlignment,
    AlignmentGeometry? actionAlignment,
    double? titleSpacing,
    EdgeInsets? leadingPadding,
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
      actions: actions ?? this.actions,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      leadingAlignment: leadingAlignment ?? this.leadingAlignment,
      actionAlignment: actionAlignment ?? this.actionAlignment,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      leadingPadding: leadingPadding ?? this.leadingPadding,
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
    this.hideBack = false,
    this.disableBack = false,
    this.appbarConfig,
  });

  final String? title;
  final Widget? titleWidget;
  final Function()? onBackPress;
  final Widget? leading;
  final bool hideBack;
  final bool disableBack;
  final AppbarConfig? appbarConfig;

  @override
  Size get preferredSize => Size.fromHeight(
    (appbarConfig?.height?.h ?? CoreKit.instance.appbarConfig.height?.h) ?? kToolbarHeight.h,
  );

  @override
  Widget build(BuildContext context) { 
    // Merge local config with the global one from CoreKit.
    // Properties defined in `appbarConfig` will override the global ones.
    final AppbarConfig config = CoreKit.instance.appbarConfig.copyWith(
      onBack: appbarConfig?.onBack,
      backIcon: appbarConfig?.backIcon,
      backButton: appbarConfig?.backButton,
      decoration: appbarConfig?.decoration,
      backgroundColor: appbarConfig?.backgroundColor,
      height: appbarConfig?.height,
      iconColor: appbarConfig?.iconColor,
      titleColor: appbarConfig?.titleColor,
      actions: appbarConfig?.actions,
      titleAlignment: appbarConfig?.titleAlignment,
      leadingAlignment: appbarConfig?.leadingAlignment,
      actionAlignment: appbarConfig?.actionAlignment,
      titleSpacing: appbarConfig?.titleSpacing,
      leadingPadding: appbarConfig?.leadingPadding,
    );

    // Determine the background color for calculating text/icon contrast.
    // We prioritize a solid background color. If a complex decoration (like a gradient)
    // is used, the user should provide explicit icon/title colors for readability.
    // final Color effectiveBackgroundColorForContrast =
    //     config.backgroundColor ??
    //     Theme.of(context).appBarTheme.backgroundColor ??
    //     Theme.of(context).scaffoldBackgroundColor;


    final backgroundColor =
        config.backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;

    // Determine the final decoration for the app bar container.
    // A provided `decoration` takes precedence over `backgroundColor`.
    final Decoration finalDecoration =
        config.decoration?.call() ??
        BoxDecoration(
          color: backgroundColor,
        );

    final contrastColor = resolveTextColorFromDecoration(finalDecoration);
    final leadingButton = _buildLeadingButton(config, contrastColor);

    

    // Use Material for elevation and to ensure ink splashes from buttons are visible.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: contrastColor == Colors.white ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        decoration: finalDecoration,
        child: SafeArea(
          top: true,
          bottom: false,
          child: SizedBox(
            height: preferredSize.height,
            child: Row( 
            children: [
              // --- Leading Widget ---
              if (!hideBack)
                Align(
                  alignment: config.leadingAlignment ?? Alignment.centerLeft,
                  child: leadingButton,
                ),

                if (config.titleSpacing > 0) SizedBox(width: config.titleSpacing.w),

              // --- Title Widget ---
                Expanded(
                  child: Align(
                    alignment: config.titleAlignment ?? Alignment.center,
                  child: _titleBuilder(config, contrastColor),
               
                  ),
                ),

              // --- Action Widgets ---
              if (config.actions?.isNotEmpty == true)
                Align(
                  alignment: config.actionAlignment ?? Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: config.actions!),
                  ),
                ),
            ],
            ),
          ),
        )
      ),
    );
  }

  Widget _titleBuilder(AppbarConfig config, Color contrastColor) {
    return titleWidget ??
        CommonText(
          text: title ?? '',
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
          textColor: config.titleColor?.call() ?? contrastColor,
        );
  }

  Widget _buildLeadingButton(AppbarConfig config, Color contrastColor) {
    if (hideBack) return const SizedBox.shrink();

    final Widget buttonContent =
        leading ?? // 1. Use widget provided to CommonAppBar
        config.backButton ?? // 2. Use widget from AppbarConfig
        Icon(
          // 3. Use default icon
          config.backIcon.icon,
          size: config.backIcon.size ?? 25.w,
          color: config.iconColor?.call() ?? contrastColor,
        );

    return GestureDetector(
      onTap: () {
        onBackPress?.call();
        if (!disableBack) {
          config.onBack?.call();
        }
      },
      child: Container(
        color: Colors.transparent, // For better hit-testing on transparent areas
        padding: config.leadingPadding,
        child: buttonContent,
      ),
    );
  }

  // // / Calculate contrast color based on background brightness
  // Color _getContrastColor(Color backgroundColor) {
  //   // Calculate relative luminance
  //   final luminance = backgroundColor.computeLuminance();
  //   // A threshold of 0.5 is standard for distinguishing light from dark.
  //   return luminance > 0.5 ? Colors.black : Colors.white;
  // }

  Color resolveTextColorFromDecoration(Decoration? decoration) {
    if (decoration == null) {
      return Colors.black;
    }

    if (decoration is BoxDecoration) {
      if (decoration.color != null) {
        return _textFromColor(decoration.color!);
      }

      if (decoration.gradient != null) {
        return _textFromGradient(decoration.gradient!);
      }
    }

    if (decoration is ShapeDecoration) {
      if (decoration.color != null) {
        return _textFromColor(decoration.color!);
      }

      if (decoration.gradient != null) {
        return _textFromGradient(decoration.gradient!);
      }
    }

    if (decoration is FlutterLogoDecoration) {
      return Colors.black;
    }

    return Colors.black;
  }

  Color _textFromColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

Color _textFromGradient(Gradient gradient) {
    double luminance = 0;

    for (final color in gradient.colors) {
      luminance += color.computeLuminance();
    }

    final avg = luminance / gradient.colors.length;

    return avg > 0.5 ? Colors.black : Colors.white;
  }
}
