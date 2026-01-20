/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:03:11
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field_v2/country_picker_dialog.dart';
import 'package:intl_phone_field_v2/intl_phone_field.dart';
import 'package:intl_phone_field_v2/phone_number.dart';

import 'validation_type.dart';

class CommonPhoneNumberTextFiled extends StatelessWidget {
  const CommonPhoneNumberTextFiled({
    this.controller,
    required this.countryChange,
    super.key,
    this.initalCountryCode = 'US',
    this.isReadOnly = false,
    this.borderColor,
    this.initialText,
    this.showActionButton = false,
    this.actionButtonIcon,
    this.backgroundColor,
    this.borderWidth = 1.2,
    this.showValidationMessage = true,
    this.textAlign = TextAlign.left,
    this.hintText,
    this.labelText,
    this.paddingHorizontal = 16,
    this.paddingVertical = 14,
    this.borderRadius,
    required this.textInputAction,
    this.hint = 'Enter your phone number',
  });

  final String initalCountryCode;
  final TextEditingController? controller;
  final Function(PhoneNumber value) countryChange;
  final double borderWidth;
  final String? initialText;
  final bool isReadOnly;
  final String? hintText;
  final String? labelText;
  final Color? borderColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double? borderRadius;
  final TextInputAction textInputAction;
  final bool showActionButton;
  final Widget? actionButtonIcon;
  final Color? backgroundColor;
  final bool showValidationMessage;
  final TextAlign textAlign;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? 12.r);
    final effectiveBorderColor = borderColor ?? theme.dividerColor;

    return IntlPhoneField(
      initialCountryCode: initalCountryCode,
      controller: controller,
      readOnly: isReadOnly,
      textInputAction: textInputAction,
      textAlign: textAlign,
      validator: (value) => showValidationMessage
          ? InputHelper.validate(ValidationType.validatePhone, value?.completeNumberWithPlus ?? '')
          : null,
      style: (theme.textTheme.bodyMedium ?? CoreKit.instance.defaultTextStyle)?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
      keyboardType: InputHelper.getKeyboardType(ValidationType.validatePhone),
      inputFormatters: InputHelper.getInputFormatters(ValidationType.validatePhone),

      // --- Decoration Section ---
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        fillColor: backgroundColor ?? theme.cardColor,
        filled: backgroundColor != null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        // Adding the action button if enabled
        suffixIcon: showActionButton ? actionButtonIcon : null,

        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveBorderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveBorderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: theme.primaryColor, width: borderWidth + 0.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: borderWidth),
        ),
      ),

      // --- Dropdown/Flag Section ---
      flagsButtonPadding: const EdgeInsets.only(left: 12, right: 8),
      dropdownIconPosition: IconPosition.trailing,
      dropdownTextStyle: (theme.textTheme.bodyMedium ?? CoreKit.instance.defaultTextStyle)
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),

      // Ensures the vertical line between flag and text is clean
      showCountryFlag: true,
      textAlignVertical: TextAlignVertical.center,
      onChanged: countryChange,

      // Picker Dialog styling
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: theme.scaffoldBackgroundColor,
        searchFieldInputDecoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
