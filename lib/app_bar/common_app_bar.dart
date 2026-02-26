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
  final Color Function()? iconColor;

  /// Custom title color
  final Color Function()? titleColor;

  final List<Widget> actions;

  final AlignmentGeometry? titleAlignment;

  final AlignmentGeometry? leadingAlignment;

  final AlignmentGeometry? actionAlignment;

  

  AppbarConfig({
    this.onBack,
    this.backIcon = const Icon(Icons.arrow_back_ios, size: 25),
    this.backButton,
    this.decoration,
    this.backgroundColor,
    this.height,
    this.iconColor,
    this.titleColor,
    this.actions = const [],
    this.titleAlignment,
    this.leadingAlignment,
    this.actionAlignment
  });

  AppbarConfig copyWith({
    Function()? onBack,
    Icon? backIcon,
    Widget? backButton,
    BoxDecoration? decoration,
    Color? backgroundColor,
    double? height,
    Color Function()? iconColor,
    Color Function()? titleColor,
    List<Widget>? actions,
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
    // Determine the effective background color

    return LayoutBuilder(
      builder: (context, constraints) {
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
          actions: appbarConfig?.actions.isNotEmpty == true
              ? appbarConfig!.actions
              : CoreKit.instance.appbarConfig.actions,

          titleAlignment:
              appbarConfig?.titleAlignment ?? CoreKit.instance.appbarConfig.titleAlignment,
          leadingAlignment:
              appbarConfig?.leadingAlignment ?? CoreKit.instance.appbarConfig.leadingAlignment,
          actionAlignment:
              appbarConfig?.actionAlignment ?? CoreKit.instance.appbarConfig.actionAlignment
    );

        final effectiveBackgroundColor =
            config.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    // Calculate contrast color for icons and text
    final contrastColor = _getContrastColor(effectiveBackgroundColor);

    // Calculate leading width
    final leadingWidth = hideBack ? 0.0 : 56.0.w;

        final leadingWidget =
            leading ??
            (config.backButton == null
                ? Icon(
                    config.backIcon.icon,
                    size: config.backIcon.size ?? 25.w,
                    color: config.iconColor?.call() ?? contrastColor,
                  )
                : config.backButton!);

    final appBar = AppBar(
      backgroundColor: config.decoration != null ? Colors.transparent : effectiveBackgroundColor,
     
      toolbarHeight: config.height?.h ?? kToolbarHeight,

      // Set icon theme for leading and actions
          iconTheme: IconThemeData(color: config.iconColor?.call() ?? contrastColor),
          actionsIconTheme: IconThemeData(color: config.iconColor?.call() ?? contrastColor),

      leadingWidth: leadingWidth,

          leading: null,
          actions: const [],

      // Use title only when no custom alignment is needed
          title: null,
          

          flexibleSpace: Container(
            decoration: config.decoration,
            height: preferredSize.height,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  children: [
                    // Leading
                    if (!hideBack)
                      Align(
                        alignment: config.leadingAlignment ?? .topLeft,
                        child: _getLeading(config, leadingWidget),
                      ),

                    // Title
                    Expanded(
                      child: Align(
                        alignment: config.titleAlignment ?? Alignment.centerLeft,
                        child:
                            titleWidget ??
                            CommonText(
                              text: title ?? '',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                              textColor: config.titleColor?.call() ?? contrastColor,
                            ),
                      ),
                    ),

                    // Actions
                    if (config.actions.isNotEmpty)
                      Align(
                        alignment: config.actionAlignment ?? .topRight,
                        child: Row(mainAxisSize: MainAxisSize.min, children: config.actions),
                      ),
                  ],
                ),
              ),
            ),
          )
    );

        return appBar;
      },
    );
  }

  Widget _getLeading(AppbarConfig config, Widget leadingWidget) {
    return hideBack
        ? SizedBox.shrink()
        : SafeArea(
            bottom: false,
            child: Container(
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
                child: leadingWidget,
              ),
            ),
          );
  }

  // / Calculate contrast color based on background brightness
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.96 ? Colors.black : Colors.white;
  }

  
}
