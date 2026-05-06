/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:03:11
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit_internal.dart';
import 'package:core_kit/text_field/custom_intl.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/text_field/input_formatters/phone_input_formater.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field_v2/country_picker_dialog.dart';
import 'package:intl_phone_field_v2/phone_number.dart';

class CommonPhoneNumberTextField extends StatelessWidget {
  const CommonPhoneNumberTextField({
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
    this.pickerDialogStyle,
    this.hintStyle,
    this.onSave,
    this.onChanged,
  });

  final String initalCountryCode;

  /// Called when the field loses focus (on save).
  final void Function(PhoneNumber value)? onSave;

  /// Called on every keystroke.
  final void Function(PhoneNumber value)? onChanged;

  /// Called only when the country code actually changes.
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
  final TextStyle? hintStyle;
  final PickerDialogStyle? pickerDialogStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? 12.r);
    final effectiveBorderColor = borderColor ?? theme.dividerColor;

    return CustomIntl(
      initialCountryCode: initalCountryCode,
      initialValue: initialText,
      readOnly: isReadOnly,
      textInputAction: textInputAction,
      textAlign: textAlign,

      // Formatter: counts only digits, dashes are cosmetic
      inputFormatters: [PhoneNumberFormatter()],

      onSaved: (value) {
        if (value != null) onSave?.call(value);
      },
      onChanged: (value) {
        onChanged?.call(value);
      },

      // Fires only when the user picks a different country flag
      onCountryChanged: (country) {
        // Re-wrap into a PhoneNumber so the caller always gets a consistent type.
        // completeNumber and number will be empty until the user types digits —
        // that is expected behaviour for a country-change event.
        countryChange(
          PhoneNumber(
            countryISOCode: country.code,
            countryCode: '+${country.dialCode}',
            number: '',
          ),
        );
      },

      style: (theme.textTheme.bodyMedium ?? coreKitInstance.defaultTextStyle)
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
      keyboardType: InputHelper.getKeyboardType(ValidationType.validatePhone),

      // --- Decoration ---
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        fillColor: backgroundColor ?? theme.cardColor,
        filled: backgroundColor != null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        suffixIcon: showActionButton ? actionButtonIcon : null,
        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: borderWidth + 0.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: borderWidth,
          ),
        ),
      ),

      // --- Dropdown / Flag ---
      flagsButtonPadding: const EdgeInsets.only(left: 12, right: 8),
      dropdownIconPosition: IconPosition.trailing,
      dropdownTextStyle:
          (theme.textTheme.bodyMedium ?? coreKitInstance.defaultTextStyle)
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
      showCountryFlag: true,
      textAlignVertical: TextAlignVertical.center,

      // --- Picker Dialog ---
      pickerDialogStyle:
          pickerDialogStyle ??
          PickerDialogStyle(
            backgroundColor: theme.scaffoldBackgroundColor,
            searchFieldInputDecoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  hintStyle ??
                  _getStyle(
                    fontSize:
                        coreKitInstance
                            .theme
                            .inputDecorationTheme
                            .hintStyle
                            ?.fontSize ??
                        16.sp,
                    fontStyle:
                        coreKitInstance
                            .theme
                            .inputDecorationTheme
                            .hintStyle
                            ?.fontStyle ??
                        FontStyle.italic,
                    textColor: _hintColor(),
                  ),
              suffixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
    );
  }

  TextStyle _getStyle({
    FontWeight? fontWeight,
    double? fontSize,
    Color? textColor,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: coreKitInstance.fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: textColor,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // Renamed from hintColor() → _hintColor() to follow private naming convention
  Color _hintColor() {
    return coreKitInstance.theme.inputDecorationTheme.hintStyle?.color ??
        coreKitInstance.outlineColor;
  }
}
