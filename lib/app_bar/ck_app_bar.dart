import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CkAppBarConfig {
  /// ()=> Get.back() or Navigator.pop(context) etc
  final Function()? onBack;
  Function()? get getBack => onBack;

  final Icon backIcon;
  final Widget? backButton;
  final BoxDecoration Function()? decoration;
  final Color? backgroundColor;
  final double? height;
  final Color Function()? iconColor;
  final Color Function()? titleColor;
  final List<Widget>? actions;
  final AlignmentGeometry? titleAlignment;
  final AlignmentGeometry? leadingAlignment;
  final AlignmentGeometry? actionAlignment;
  final double titleSpacing;
  final EdgeInsets leadingPadding;
  final EdgeInsets actionsPadding;
  final Widget Function(String title)? titleBuilder;

  CkAppBarConfig({
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
    this.titleBuilder,
    this.leadingPadding = const EdgeInsets.only(left: 16.0, right: 8.0),
    this.actionsPadding = const EdgeInsets.only(right: 16.0, left: 8.0),
  });

  CkAppBarConfig copyWith({
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
    Widget Function(String title)? titleBuilder,
    EdgeInsets? actionsPadding,
  }) {
    return CkAppBarConfig(
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
      titleBuilder: titleBuilder ?? this.titleBuilder,
      actionsPadding: actionsPadding ?? this.actionsPadding,
    );
  }
}

/// @deprecated Use [CkAppBarConfig] instead.
@Deprecated('Use CkAppBarConfig instead')
typedef AppbarConfig = CkAppBarConfig;

class CkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CkAppBar({
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
  final CkAppBarConfig? appbarConfig;

  @override
  Size get preferredSize => Size.fromHeight(
    (appbarConfig?.height?.h ?? coreKitInstance.appbarConfig.height?.h) ??
        kToolbarHeight.h,
  );

  @override
  Widget build(BuildContext context) {
    final config = coreKitInstance.appbarConfig.copyWith(
      onBack: appbarConfig?.onBack,
      backIcon: appbarConfig?.backIcon,
      actionsPadding: appbarConfig?.actionsPadding,
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
      titleBuilder: appbarConfig?.titleBuilder,
    );

    final backgroundColor =
        config.backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;

    final Decoration finalDecoration =
        config.decoration?.call() ?? BoxDecoration(color: backgroundColor);

    final contrastColor = resolveTextColorFromDecoration(finalDecoration);
    final leadingButton = _buildLeadingButton(config, contrastColor);

    final isCenter =
        config.titleAlignment == Alignment.center ||
        config.leadingAlignment == Alignment.bottomCenter ||
        config.actionAlignment == Alignment.topCenter;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: contrastColor == Colors.white
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: contrastColor == Colors.white
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Container(
        decoration: finalDecoration,
        child: SafeArea(
          top: true,
          bottom: false,
          child: SizedBox(
            height: preferredSize.height,
            child: isCenter
                ? _appbarStackBased(config, leadingButton, contrastColor)
                : _appbarRowBased(config, leadingButton, contrastColor),
          ),
        ),
      ),
    );
  }

  Widget _appbarStackBased(
    CkAppBarConfig config,
    Widget leadingButton,
    Color contrastColor,
  ) {
    return Stack(
      children: [
        if (!hideBack)
          Align(
            alignment: config.leadingAlignment ?? Alignment.centerLeft,
            child: leadingButton,
          ),
        Align(
          alignment: config.titleAlignment ?? Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: config.titleSpacing > 0 ? config.titleSpacing.w : 0,
            ),
            child: _titleBuilder(config, contrastColor),
          ),
        ),
        if (config.actions?.isNotEmpty == true)
          Align(
            alignment: config.actionAlignment ?? Alignment.centerRight,
            child: Padding(
              padding: config.actionsPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: config.actions!,
              ),
            ),
          ),
      ],
    );
  }

  Row _appbarRowBased(
    CkAppBarConfig config,
    Widget leadingButton,
    Color contrastColor,
  ) {
    return Row(
      children: [
        if (!hideBack)
          Align(
            alignment: config.leadingAlignment ?? Alignment.centerLeft,
            child: leadingButton,
          ),
        if (config.titleSpacing > 0) SizedBox(width: config.titleSpacing.w),
        Expanded(
          child: Align(
            alignment: config.titleAlignment ?? Alignment.center,
            child: _titleBuilder(config, contrastColor),
          ),
        ),
        if (config.actions?.isNotEmpty == true)
          Align(
            alignment: config.actionAlignment ?? Alignment.centerRight,
            child: Padding(
              padding: config.actionsPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: config.actions!,
              ),
            ),
          ),
      ],
    );
  }

  Widget _titleBuilder(CkAppBarConfig config, Color contrastColor) {
    return titleWidget ??
        config.titleBuilder?.call(title ?? '') ??
        CkText(
          text: title ?? '',
          fontWeight: FontWeight.w600,
          fontSize:
              coreKitInstanceSingleton
                  .instance
                  .theme
                  .appBarTheme
                  .titleTextStyle
                  ?.fontSize ??
              18,
          textColor: config.titleColor?.call() ?? contrastColor,
        );
  }

  Widget _buildLeadingButton(CkAppBarConfig config, Color contrastColor) {
    if (hideBack) return const SizedBox.shrink();

    final buttonContent =
        leading ??
        config.backButton ??
        Icon(
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
        color: Colors.transparent,
        padding: config.leadingPadding,
        child: buttonContent,
      ),
    );
  }

  Color resolveTextColorFromDecoration(Decoration? decoration) {
    if (decoration == null) return Colors.black;

    if (decoration is BoxDecoration) {
      if (decoration.color != null) return _textFromColor(decoration.color!);
      if (decoration.gradient != null)
        return _textFromGradient(decoration.gradient!);
    }

    if (decoration is ShapeDecoration) {
      if (decoration.color != null) return _textFromColor(decoration.color!);
      if (decoration.gradient != null)
        return _textFromGradient(decoration.gradient!);
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

/// @deprecated Use [CkAppBar] instead.
@Deprecated('Use CkAppBar instead')
typedef CommonAppBar = CkAppBar;
