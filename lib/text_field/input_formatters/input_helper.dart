import 'package:core_kit/utils/core_kit_string.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../validation_type.dart';
import 'date_input_formatter.dart';
import 'phone_input_formater.dart';

class InputHelper {
  static List<TextInputFormatter> getInputFormatters(ValidationType type) {
    switch (type) {
      case ValidationType.validateDate:
        return [
          DateFormatter(), // Deny spaces for email
        ];

      case ValidationType.validateEmail:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny spaces for email
        ];

      case ValidationType.validatePhone:
        return [
          PhoneNumberFormatter(), // Allow only digits
        ];

      case ValidationType.validatePassword:
        return [
          LengthLimitingTextInputFormatter(20), // Limit password length to 20
        ];

      case ValidationType.validateNumber:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
        ];

      case ValidationType.validateCreditCard:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(16), // Limit to 16 digits
        ];

      case ValidationType.validatePostalCode:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(5), // Limit to 5 digits
        ];

      case ValidationType.validateCurrency:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          TextInputFormatter.withFunction((oldValue, newValue) {
            final text = newValue.text;
            if (text.contains(RegExp(r'^\d*\.?\d{0,2}'))) {
              return newValue;
            }
            return oldValue;
          }), // Handle currency decimal points
        ];

      case ValidationType.validateAlphaNumeric:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9]'),
          ), // Allow only alphanumeric characters
        ];

      case ValidationType.validateUsername:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9_]'),
          ), // Allow alphanumeric and underscores
        ];

      case ValidationType.validateOTP:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(6), // Limit to 6 digits
        ];

      case ValidationType.validateTime:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')), // Allow numbers and colon
        ];

      case ValidationType.validateIP:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(15), // Limit to a valid IPv4 length
        ];
      case ValidationType.validateFullName:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z'\- ]"), // Allow letters, apostrophes, hyphens, and spaces
          ),
        ];
      case ValidationType.validateNID:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits for NID
        ];

      default:
        return [];
    }
  }

  static TextInputType getKeyboardType(ValidationType type) {
    switch (type) {
      case ValidationType.validateRequired:
        return TextInputType.text;

      case ValidationType.validateEmail:
        return TextInputType.emailAddress;

      case ValidationType.validatePhone:
        return TextInputType.phone;

      case ValidationType.validatePassword:
        return TextInputType.visiblePassword;

      case ValidationType.validateDate:
        return TextInputType.datetime;

      case ValidationType.validateConfirmPassword:
        return TextInputType.visiblePassword;

      case ValidationType.validateURL:
        return TextInputType.url;

      case ValidationType.validateNumber:
        return TextInputType.number;

      case ValidationType.validateCreditCard:
        return TextInputType.number;

      case ValidationType.validatePostalCode:
        return TextInputType.number;

      case ValidationType.validateMinLength:
        return TextInputType.text;

      case ValidationType.validateMaxLength:
        return TextInputType.text;

      case ValidationType.validateCustomPattern:
        return TextInputType.text;

      case ValidationType.validateDateRange:
        return TextInputType.datetime;

      case ValidationType.validateAlphaNumeric:
        return TextInputType.text;

      case ValidationType.validateUsername:
        return TextInputType.text;

      case ValidationType.validateTime:
        return TextInputType.datetime;

      case ValidationType.validateOTP:
        return TextInputType.number;

      case ValidationType.validateCurrency:
        return const TextInputType.numberWithOptions(decimal: true);

      case ValidationType.validateIP:
        return TextInputType.number;

      case ValidationType.validateFullName:
        return TextInputType.text;
      case ValidationType.validateNID:
        return TextInputType.number;
      case ValidationType.notRequired:
        return TextInputType.text;
      case ValidationType.validateYear:
        return TextInputType.number;
    }
  }

  // Required field check
  static String? validate(
    ValidationType type,
    String? value, {
    int? minLength,
    int? maxLength,
    DateTime? startDate,
    DateTime? endDate,
    String? originalPassword,
  }) {
    switch (type) {
      case ValidationType.validateRequired:
        return _validateRequired(value);

      case ValidationType.validateEmail:
        return _validateEmail(value);

      case ValidationType.validatePhone:
        return _validatePhone(value);

      case ValidationType.validatePassword:
        return _validatePassword(value);

      case ValidationType.validateDate:
        return _validateDate(value);

      case ValidationType.validateConfirmPassword:
        return _validateConfirmPassword(value, originalPassword);

      case ValidationType.validateURL:
        return _validateURL(value);

      case ValidationType.validateNumber:
        return _validateNumber(value);

      case ValidationType.validateCreditCard:
        return _validateCreditCard(value);

      case ValidationType.validatePostalCode:
        return _validatePostalCode(value);

      case ValidationType.validateMinLength:
        return _validateMinLength(value, minLength!);

      case ValidationType.validateMaxLength:
        return _validateMaxLength(value, maxLength!);

      case ValidationType.validateCustomPattern:
        return _validateCustomPattern(
          value,
          '',
          '',
        ); // Example, you can pass pattern and error message here

      case ValidationType.validateDateRange:
        return _validateDateRange(value, startDate!, endDate!);

      case ValidationType.validateAlphaNumeric:
        return _validateAlphaNumeric(value);

      case ValidationType.validateUsername:
        return _validateUsername(value);

      case ValidationType.validateTime:
        return _validateTime(value);

      case ValidationType.validateOTP:
        return _validateOTP(value);

      case ValidationType.validateCurrency:
        return _validateCurrency(value);

      case ValidationType.validateIP:
        return _validateIP(value);
      case ValidationType.validateFullName:
        return _validateFullName(value);
      case ValidationType.validateNID:
        return _validateNID(value);
      case ValidationType.notRequired:
        return null;
      case ValidationType.validateYear:
        return _validateYear(value);
    }
  }

  static String? _validateYear(String? value) {
    final yearRegex = RegExp(r'^\d{4}$'); // Assuming year is exactly 4 digits
    if (value == null || value.isEmpty) {
      return CoreKitString.yearRequired;
    }
    if (!yearRegex.hasMatch(value)) {
      return CoreKitString.yearInvalid;
    }
    return null; // Return null if year is valid
  }


  static String? _validateNID(String? value) {
    final nidRegex = RegExp(r'^\d{12}$'); // Assuming NID is exactly 12 digits
    if (value == null || value.isEmpty) {
      return CoreKitString.nidRequired;
    }
    if (!nidRegex.hasMatch(value)) {
      return CoreKitString.nidInvalid;
    }
    return null; // Return null if NID is valid
  }

  static String? _validateFullName(String? value) {
    final nameRegex = RegExp(r"^[a-zA-Z]+(?:[ '-][a-zA-Z]+)*$");
    if (value == null || value.isEmpty) {
      return CoreKitString.fullNameRequired;
    }
    if (!nameRegex.hasMatch(value)) {
      return CoreKitString.fullNameInvalid;
    }
    return null; // Return null if the name is valid
  }

  static String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    return null;
  }

  // Email validation
  static String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return CoreKitString.invalidEmail;
    }
    return null;
  }

  // Phone number validation
  static String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$'); // Only xxx-xxx-xxxx
    if (!phoneRegex.hasMatch(value)) {
      return CoreKitString.invalidPhone;
    }
    return null;
  }

  // Password validation
  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return CoreKitString.invalidPassword;
    }
    return null;
  }

  // Date validation (YYYY-MM-DD format)
  static String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      dateFormat.parseStrict(value);
    } catch (e) {
      return CoreKitString.invalidDate;
    }
    return null;
  }

  // Confirm password validation
  static String? _validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    if (value != originalPassword) {
      return CoreKitString.passwordMismatch;
    }
    return null;
  }

  // URL validation
  static String? _validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,6}(\/[^\s]*)?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return CoreKitString.invalidURL;
    }
    return null;
  }

  // Numeric input validation
  static String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    if (double.tryParse(value) == null) {
      return CoreKitString.invalidNumber;
    }
    return null;
  }

  // Credit card number validation
  static String? _validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final cardRegex = RegExp(r'^\d{16}$');
    if (!cardRegex.hasMatch(value)) {
      return CoreKitString.invalidCreditCard;
    }
    return null;
  }

  // Postal code validation
  static String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final postalCodeRegex = RegExp(r'^[0-9]{5}(?:-[0-9]{4})?$');
    if (!postalCodeRegex.hasMatch(value)) {
      return CoreKitString.invalidPostalCode;
    }
    return null;
  }

  // Minimum length validation
  static String? _validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    if (value.length < minLength) {
      return CoreKitString.minLengthError(
        minLength,
      ).replaceAll('{minLength}', minLength.toString());
    }
    return null;
  }

  // Maximum length validation
  static String? _validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    if (value.length > maxLength) {
      return CoreKitString.maxLengthError(
        maxLength,
      ).replaceAll('{maxLength}', maxLength.toString());
    }
    return null;
  }

  // Custom regex pattern validation
  static String? _validateCustomPattern(String? value, String pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  // Date range validation
  static String? _validateDateRange(String? value, DateTime startDate, DateTime endDate) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parseStrict(value);
      if (date.isBefore(startDate) || date.isAfter(endDate)) {
        return CoreKitString.invalidDateRange(endDate, startDate)
            .replaceAll('{startDate}', DateFormat('yyyy-MM-dd').format(startDate))
            .replaceAll('{endDate}', DateFormat('yyyy-MM-dd').format(endDate));
      }
    } catch (e) {
      return CoreKitString.invalidDate;
    }
    return null;
  }

  // Alphanumeric input validation
  static String? _validateAlphaNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(value)) {
      return CoreKitString.alphaNumericError;
    }
    return null;
  }

  // Username validation
  static String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,15}$');
    if (!regex.hasMatch(value)) {
      return CoreKitString.usernameError;
    }
    return null;
  }

  // Time format validation
  static String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final timeRegex = RegExp(r'^[0-2]?[0-9]:[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return CoreKitString.invalidTime;
    }
    return null;
  }

  // OTP validation
  static String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value)) {
      return CoreKitString.invalidOTP;
    }
    return null;
  }

  // Currency amount validation
  static String? _validateCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final currencyRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!currencyRegex.hasMatch(value)) {
      return CoreKitString.invalidCurrency;
    }
    return null;
  }

  // IP address validation
  static String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return CoreKitString.requiredField;
    }
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    if (!ipRegex.hasMatch(value)) {
      return CoreKitString.invalidIP;
    }
    return null;
  }
}
