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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: backgroundColor ?? CoreKit.instance.backgroundColor,
    centerTitle: isCenterTitle,
    actionsPadding: const EdgeInsets.only(bottom: 10),
    leading: hideBack
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 10.0),
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
                      ? const Icon(Icons.arrow_back_ios, size: 25)
                      : CoreKit.instance.backButton!),
            ),
          ),
    actions: actions ?? _appBarActions(),

    title:
        titleWidget ?? CommonText(text: title ?? '', fontWeight: FontWeight.w600, fontSize: 18.sp),
  );

  List<Widget> _appBarActions() => [];
}
