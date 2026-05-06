/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:03:11
 * @Email: km.muzahid@gmail.com
 */
import 'dart:async';

import 'package:core_kit/core_kit_internal.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/text_field/input_formatters/phone_input_formater.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field_v2/countries.dart';
import 'package:intl_phone_field_v2/country_picker_dialog.dart';
import 'package:intl_phone_field_v2/helpers.dart';
import 'package:intl_phone_field_v2/phone_number.dart';

class CommonPhoneNumberTextField extends StatefulWidget {
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
    this.controller,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CommonPhoneNumberTextField> createState() =>
      _CommonPhoneNumberTextFieldState();
}

class _CommonPhoneNumberTextFieldState
    extends State<CommonPhoneNumberTextField> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;
  late String number;
  late List<TextInputFormatter> _inputFormatters;

  @override
  void initState() {
    super.initState();
    _countryList = countries;
    filteredCountries = _countryList;
    number = widget.initialText ?? '';
    _inputFormatters = [PhoneNumberFormatter()];

    var rawDigits = number.replaceAll(RegExp(r'[^\d]'), '');

    // 1. Detect country from initialText if it starts with '+'
    if (number.startsWith('+') && rawDigits.isNotEmpty) {
      Country? detectedCountry;
      // Sort countries by dial code length descending to match longest possible code (e.g. +1 242 vs +1)
      final sortedCountries = List<Country>.from(_countryList)
        ..sort((a, b) => b.fullCountryCode.length.compareTo(a.fullCountryCode.length));

      for (final country in sortedCountries) {
        if (rawDigits.startsWith(country.fullCountryCode)) {
          detectedCountry = country;
          break;
        }
      }

      if (detectedCountry != null) {
        _selectedCountry = detectedCountry;
        rawDigits = rawDigits.replaceFirst(_selectedCountry.fullCountryCode, '');
      } else {
        // Fallback if dial code not found
        _selectedCountry = _countryList.firstWhere(
          (item) => item.code == (widget.initalCountryCode),
          orElse: () => _countryList.first,
        );
      }
    } else {
      // 2. Default behavior: use initalCountryCode
      _selectedCountry = _countryList.firstWhere(
        (item) => item.code == (widget.initalCountryCode),
        orElse: () => _countryList.first,
      );

      // Strip country code if it was provided without '+' but still matches
      if (rawDigits.startsWith(_selectedCountry.fullCountryCode)) {
        rawDigits = rawDigits.replaceFirst(_selectedCountry.fullCountryCode, '');
      }
    }

    _updateFormatterMaxDigits();

    // Format the number properly (e.g. xxx-xxx-xxxx)
    number = PhoneNumberFormatter.formatString(
      rawDigits,
      maxDigits: _selectedCountry.maxLength,
    );

    if (widget.controller != null) {
      widget.controller!.text = number;
      widget.controller!.selection = TextSelection.collapsed(
        offset: number.length,
      );
    }
  }

  /// Updates the PhoneNumberFormatter's maxDigits to match the selected country.
  void _updateFormatterMaxDigits() {
    for (final f in _inputFormatters) {
      if (f is PhoneNumberFormatter) {
        f.maxDigits = _selectedCountry.maxLength;
        break;
      }
    }
  }

  /// Computes the max character length including dashes inserted by the formatter.
  int get _formattedMaxLength {
    final max = _selectedCountry.maxLength;
    var dashes = 0;
    if (max > 3) dashes++;
    if (max > 6) dashes++;
    return max + dashes;
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          languageCode: 'en',
          style:
              widget.pickerDialogStyle ??
              PickerDialogStyle(
                backgroundColor: coreKitInstance.theme.scaffoldBackgroundColor,
                searchFieldInputDecoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle:
                      widget.hintStyle ??
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
          filteredCountries: filteredCountries,
          searchText: widget.hint,
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            _updateFormatterMaxDigits();

            // Re-format existing number to match the new country's max length
            if (widget.controller != null) {
              final currentDigits = widget.controller!.text.replaceAll(RegExp(r'[^\d]'), '');
              widget.controller!.text = PhoneNumberFormatter.formatString(
                currentDigits,
                maxDigits: _selectedCountry.maxLength,
              );
              widget.controller!.selection = TextSelection.collapsed(
                offset: widget.controller!.text.length,
              );
            } else {
              final currentDigits = number.replaceAll(RegExp(r'[^\d]'), '');
              number = PhoneNumberFormatter.formatString(
                currentDigits,
                maxDigits: _selectedCountry.maxLength,
              );
            }

            widget.countryChange(
              PhoneNumber(
                countryISOCode: country.code,
                countryCode: '+${country.dialCode}',
                number: '',
              ),
            );
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = BorderRadius.circular(
      widget.borderRadius ?? 12.r,
    );
    final effectiveBorderColor = widget.borderColor ?? theme.dividerColor;

    return TextFormField(
      initialValue: (widget.controller == null) ? number : null,
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.isReadOnly,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAlign,
      autovalidateMode: widget.autovalidateMode,
      keyboardType: InputHelper.getKeyboardType(ValidationType.validatePhone),
      inputFormatters: _inputFormatters,
      style: (theme.textTheme.bodyMedium ?? coreKitInstance.defaultTextStyle)
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        fillColor: widget.backgroundColor ?? theme.cardColor,
        filled: widget.backgroundColor != null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.paddingHorizontal,
          vertical: widget.paddingVertical,
        ),
        prefixIcon: _buildFlagsButton(),
        suffixIcon: widget.showActionButton ? widget.actionButtonIcon : null,
        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: widget.borderWidth + 0.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: widget.borderWidth,
          ),
        ),
      ),
      onSaved: (value) {
        final digits = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
        widget.onSave?.call(
          PhoneNumber(
            countryISOCode: _selectedCountry.code,
            countryCode: '+${_selectedCountry.dialCode}',
            number: digits,
          ),
        );
      },
      onChanged: (value) {
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        widget.onChanged?.call(
          PhoneNumber(
            countryISOCode: _selectedCountry.code,
            countryCode: '+${_selectedCountry.dialCode}',
            number: digits,
          ),
        );
      },
      validator: (value) {
        if (!widget.showValidationMessage) return null;
        final digits = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');

        if (digits.isEmpty || !isNumeric(digits)) {
          return 'Invalid Mobile Number';
        }

        final isValidLength =
            digits.length >= _selectedCountry.minLength &&
            digits.length <= _selectedCountry.maxLength;
        if (!isValidLength) return 'Invalid Mobile Number';

        return null;
      },
      maxLength: _formattedMaxLength,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) {
            final dashes =
                (currentLength > 3 ? 1 : 0) + (currentLength > 7 ? 1 : 0);
            final digitCount = (currentLength - dashes).clamp(
              0,
              _selectedCountry.maxLength,
            );
            return Text(
              '$digitCount/${_selectedCountry.maxLength}',
              style: const TextStyle(fontSize: 12),
            );
          },
    );
  }

  Widget _buildFlagsButton() {
    return InkWell(
      onTap: widget.isReadOnly ? null : _changeCountry,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (kIsWeb)
              Image.asset(
                'assets/flags/${_selectedCountry.code.toLowerCase()}.png',
                package: 'intl_phone_field_v2',
                width: 32,
              )
            else
              Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            FittedBox(
              child: Text(
                '+${_selectedCountry.dialCode}',
                style:
                    (Theme.of(context).textTheme.bodyMedium ??
                            coreKitInstance.defaultTextStyle)
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8),
          ],
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

  Color _hintColor() {
    return coreKitInstance.theme.inputDecorationTheme.hintStyle?.color ??
        coreKitInstance.outlineColor;
  }
}
