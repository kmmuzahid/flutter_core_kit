import 'package:core_kit/button/common_button.dart';
import 'package:core_kit/form/custom_form.dart';
import 'package:core_kit/initializer.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

Future commonDialog({
  required Widget child,
  required BuildContext context,
  bool isDismissible = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (dialogContext) => Dialog(
      backgroundColor: CoreKit.instance.surfaceBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: child,
      ),
    ),
  );
}

Future CommonDialogWithActions({
  required List<Widget> content,
  required BuildContext context,
  required String title,
  String? subTitle,
  bool isDismissible = true,
  final bool validationRequired = false,
  required Function() onConfirm,
  Function()? onCancel,
  String action = 'Confirm',
  String cancel = 'Cancel',
}) {
  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (dialogContext) => Dialog(
      backgroundColor: CoreKit.instance.surfaceBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: validationRequired
            ? CustomForm(
                builder: (context, formKey) =>
                    _body(title, subTitle, content, onConfirm, onCancel, formKey, action, cancel),
              )
            : _body(title, subTitle, content, onConfirm, onCancel, null, action, cancel),
      ),
    ),
  );
}

Column _body(
  String title,
  String? subTitle,
  List<Widget> content,
  Function onConfirm,
  Function? onCancel,
  GlobalKey<FormState>? formKey,
  String action,
  String cancel,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CommonText(
        top: 20,
        text: title,
        fontWeight: FontWeight.w600,
        textColor: CoreKit.instance.primaryColor,
        fontSize: 24,
      ),
      if (subTitle != null)
        CommonText(
          maxLines: 3,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.left,
          bottom: 10,
          fontSize: 16,
          text: subTitle,
        ),
      ...content,
      20.height,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonButton(
            titleText: action,
            onTap: () {
              if (formKey != null) {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  onConfirm.call();
                  CoreKit.instance.appbarConfig.getBack?.call();
                }
              } else {
                onConfirm.call();
                CoreKit.instance.appbarConfig.getBack?.call();
              }
            },
          ),
          20.width,
          CommonButton(
            buttonColor: CoreKit.instance.outlineColor,
            titleText: cancel,
            onTap: () {
              onCancel?.call();
              CoreKit.instance.appbarConfig.getBack?.call();
            },
          ),
        ],
      ),
      20.height,
    ],
  );
}
