import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Future CkDialog({
  required Widget child,
  required BuildContext context,
  bool isDismissible = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (dialogContext) => Dialog(
      backgroundColor: coreKitInstance.surfaceBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: child,
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Future CkDialogWithActions({
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
      backgroundColor: coreKitInstance.surfaceBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: validationRequired
            ? CkForm(
                builder: (context, formKey) => _body(
                  title,
                  subTitle,
                  content,
                  onConfirm,
                  onCancel,
                  formKey,
                  action,
                  cancel,
                ),
              )
            : _body(
                title,
                subTitle,
                content,
                onConfirm,
                onCancel,
                null,
                action,
                cancel,
              ),
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
      CkText(
        top: 20,
        text: title,
        fontWeight: FontWeight.w600,
        textColor: coreKitInstance.primaryColor,
        fontSize: 24,
      ),
      if (subTitle != null)
        CkText(
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
          CkButton(
            titleText: action,
            onTap: () {
              if (formKey != null) {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  onConfirm.call();
                  coreKitInstance.appbarConfig.getBack?.call();
                }
              } else {
                onConfirm.call();
                coreKitInstance.appbarConfig.getBack?.call();
              }
            },
          ),
          20.width,
          CkButton(
            buttonColor: coreKitInstance.outlineColor,
            titleText: cancel,
            onTap: () {
              onCancel?.call();
              coreKitInstance.appbarConfig.getBack?.call();
            },
          ),
        ],
      ),
      20.height,
    ],
  );
}
