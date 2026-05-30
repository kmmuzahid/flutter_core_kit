import 'package:core_kit/text_field/input_formatters/date_input_formatter.dart';
import 'package:core_kit/text_field/input_formatters/phone_input_formater.dart';
import 'package:core_kit/text_field/ck_validation_type.dart';
import 'package:core_kit/utils/ck_string.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputHelper {
  static List<TextInputFormatter> getInputFormatters(CkValidationType type) {
    switch (type) {
      case CkValidationType.validateDate:
        return [
          DateFormatter(), // Deny spaces for email
        ];

      case CkValidationType.validateEmail:
        return [
          FilteringTextInputFormatter.deny(
            RegExp(r'\s'),
          ), // Deny spaces for email
        ];

      case CkValidationType.validatePhone:
        return [
          PhoneNumberFormatter(), // Allow only digits
        ];

      case CkValidationType.validatePassword:
        return [
          LengthLimitingTextInputFormatter(20), // Limit password length to 20
        ];

      case CkValidationType.validateNumber:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
        ];

      case CkValidationType.validateCreditCard:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(16), // Limit to 16 digits
        ];

      case CkValidationType.validatePostalCode:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(5), // Limit to 5 digits
        ];

      case CkValidationType.validateCurrency:
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

      case CkValidationType.validateAlphaNumeric:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9]'),
          ), // Allow only alphanumeric characters
        ];

      case CkValidationType.validateUsername:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[a-zA-Z0-9_]'),
          ), // Allow alphanumeric and underscores
        ];

      case CkValidationType.validateOTP:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(6), // Limit to 6 digits
        ];

      case CkValidationType.validateTime:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[0-9:]'),
          ), // Allow numbers and colon
        ];

      case CkValidationType.validateIP:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
          LengthLimitingTextInputFormatter(15), // Limit to a valid IPv4 length
        ];
      case CkValidationType.validateFullName:
        return [
          FilteringTextInputFormatter.allow(
            RegExp(
              r"[a-zA-Z'\- ]",
            ), // Allow letters, apostrophes, hyphens, and spaces
          ),
        ];
      case CkValidationType.validateNID:
        return [
          FilteringTextInputFormatter.digitsOnly, // Allow only digits for NID
        ];

      default:
        return [];
    }
  }

  static TextInputType getKeyboardType(CkValidationType type) {
    switch (type) {
      case CkValidationType.validateRequired:
        return TextInputType.text;

      case CkValidationType.validateEmail:
        return TextInputType.emailAddress;

      case CkValidationType.validatePhone:
        return TextInputType.phone;

      case CkValidationType.validatePassword:
        return TextInputType.visiblePassword;

      case CkValidationType.validateDate:
        return TextInputType.datetime;

      case CkValidationType.validateConfirmPassword:
        return TextInputType.visiblePassword;

      case CkValidationType.validateURL:
        return TextInputType.url;

      case CkValidationType.validateNumber:
        return TextInputType.number;

      case CkValidationType.validateCreditCard:
        return TextInputType.number;

      case CkValidationType.validatePostalCode:
        return TextInputType.number;

      case CkValidationType.validateMinLength:
        return TextInputType.text;

      case CkValidationType.validateMaxLength:
        return TextInputType.text;

      case CkValidationType.validateCustomPattern:
        return TextInputType.text;

      case CkValidationType.validateDateRange:
        return TextInputType.datetime;

      case CkValidationType.validateAlphaNumeric:
        return TextInputType.text;

      case CkValidationType.validateUsername:
        return TextInputType.text;

      case CkValidationType.validateTime:
        return TextInputType.datetime;

      case CkValidationType.validateOTP:
        return TextInputType.number;

      case CkValidationType.validateCurrency:
        return const TextInputType.numberWithOptions(decimal: true);

      case CkValidationType.validateIP:
        return TextInputType.number;

      case CkValidationType.validateFullName:
        return TextInputType.text;
      case CkValidationType.validateNID:
        return TextInputType.number;
      case CkValidationType.notRequired:
        return TextInputType.text;
      case CkValidationType.validateYear:
        return TextInputType.number;
    }
  }

  // Required field check
  static String? validate(
    CkValidationType type,
    String? value, {
    int? minLength,
    int? maxLength,
    DateTime? startDate,
    DateTime? endDate,
    String? originalPassword,
  }) {
    switch (type) {
      case CkValidationType.validateRequired:
        return _validateRequired(value);

      case CkValidationType.validateEmail:
        return _validateEmail(value);

      case CkValidationType.validatePhone:
        return _validatePhone(value);

      case CkValidationType.validatePassword:
        return _validatePassword(value);

      case CkValidationType.validateDate:
        return _validateDate(value);

      case CkValidationType.validateConfirmPassword:
        return _validateConfirmPassword(value, originalPassword);

      case CkValidationType.validateURL:
        return _validateURL(value);

      case CkValidationType.validateNumber:
        return _validateNumber(value);

      case CkValidationType.validateCreditCard:
        return _validateCreditCard(value);

      case CkValidationType.validatePostalCode:
        return _validatePostalCode(value);

      case CkValidationType.validateMinLength:
        return _validateMinLength(value, minLength!);

      case CkValidationType.validateMaxLength:
        return _validateMaxLength(value, maxLength!);

      case CkValidationType.validateCustomPattern:
        return _validateCustomPattern(
          value,
          '',
          '',
        ); // Example, you can pass pattern and error message here

      case CkValidationType.validateDateRange:
        return _validateDateRange(value, startDate!, endDate!);

      case CkValidationType.validateAlphaNumeric:
        return _validateAlphaNumeric(value);

      case CkValidationType.validateUsername:
        return _validateUsername(value);

      case CkValidationType.validateTime:
        return _validateTime(value);

      case CkValidationType.validateOTP:
        return _validateOTP(value);

      case CkValidationType.validateCurrency:
        return _validateCurrency(value);

      case CkValidationType.validateIP:
        return _validateIP(value);
      case CkValidationType.validateFullName:
        return _validateFullName(value);
      case CkValidationType.validateNID:
        return _validateNID(value);
      case CkValidationType.notRequired:
        return null;
      case CkValidationType.validateYear:
        return _validateYear(value);
    }
  }

  static String? _validateYear(String? value) {
    final yearRegex = RegExp(r'^\d{4}$'); // Assuming year is exactly 4 digits
    if (value == null || value.isEmpty) {
      return CkString.yearRequired;
    }
    if (!yearRegex.hasMatch(value)) {
      return CkString.yearInvalid;
    }
    return null; // Return null if year is valid
  }

  static String? _validateNID(String? value) {
    final nidRegex = RegExp(r'^\d{12}$'); // Assuming NID is exactly 12 digits
    if (value == null || value.isEmpty) {
      return CkString.nidRequired;
    }
    if (!nidRegex.hasMatch(value)) {
      return CkString.nidInvalid;
    }
    return null; // Return null if NID is valid
  }

  static String? _validateFullName(String? value) {
    final nameRegex = RegExp(r"^[a-zA-Z]+(?:[ '-][a-zA-Z]+)*$");
    if (value == null || value.isEmpty) {
      return CkString.fullNameRequired;
    }
    if (!nameRegex.hasMatch(value)) {
      return CkString.fullNameInvalid;
    }
    return null; // Return null if the name is valid
  }

  static String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    return null;
  }

  // Email validation
  static String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return CkString.invalidEmail;
    }
    return null;
  }

  // Phone number validation
  static String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$'); // Only xxx-xxx-xxxx
    if (!phoneRegex.hasMatch(value)) {
      return CkString.invalidPhone;
    }
    return null;
  }

  // Password validation
  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return CkString.invalidPassword;
    }
    return null;
  }

  // Date validation (YYYY-MM-DD format)
  static String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      dateFormat.parseStrict(value);
    } catch (e) {
      return CkString.invalidDate;
    }
    return null;
  }

  // Confirm password validation
  static String? _validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    if (value != originalPassword) {
      return CkString.passwordMismatch;
    }
    return null;
  }

  // URL validation
  static String? _validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,6}(\/[^\s]*)?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return CkString.invalidURL;
    }
    return null;
  }

  // Numeric input validation
  static String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    if (double.tryParse(value) == null) {
      return CkString.invalidNumber;
    }
    return null;
  }

  // Credit card number validation
  static String? _validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final cardRegex = RegExp(r'^\d{16}$');
    if (!cardRegex.hasMatch(value)) {
      return CkString.invalidCreditCard;
    }
    return null;
  }

  // Postal code validation
  static String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final postalCodeRegex = RegExp(r'^[0-9]{5}(?:-[0-9]{4})?$');
    if (!postalCodeRegex.hasMatch(value)) {
      return CkString.invalidPostalCode;
    }
    return null;
  }

  // Minimum length validation
  static String? _validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    if (value.length < minLength) {
      return CkString.minLengthError(
        minLength,
      ).replaceAll('{minLength}', minLength.toString());
    }
    return null;
  }

  // Maximum length validation
  static String? _validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    if (value.length > maxLength) {
      return CkString.maxLengthError(
        maxLength,
      ).replaceAll('{maxLength}', maxLength.toString());
    }
    return null;
  }

  // Custom regex pattern validation
  static String? _validateCustomPattern(
    String? value,
    String pattern,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  // Date range validation
  static String? _validateDateRange(
    String? value,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parseStrict(value);
      if (date.isBefore(startDate) || date.isAfter(endDate)) {
        return CkString.invalidDateRange(endDate, startDate)
            .replaceAll(
              '{startDate}',
              DateFormat('yyyy-MM-dd').format(startDate),
            )
            .replaceAll('{endDate}', DateFormat('yyyy-MM-dd').format(endDate));
      }
    } catch (e) {
      return CkString.invalidDate;
    }
    return null;
  }

  // Alphanumeric input validation
  static String? _validateAlphaNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(value)) {
      return CkString.alphaNumericError;
    }
    return null;
  }

  // Username validation
  static String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,15}$');
    if (!regex.hasMatch(value)) {
      return CkString.usernameError;
    }
    return null;
  }

  // Time format validation
  static String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final timeRegex = RegExp(r'^[0-2]?[0-9]:[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return CkString.invalidTime;
    }
    return null;
  }

  // OTP validation
  static String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value)) {
      return CkString.invalidOTP;
    }
    return null;
  }

  // Currency amount validation
  static String? _validateCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final currencyRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!currencyRegex.hasMatch(value)) {
      return CkString.invalidCurrency;
    }
    return null;
  }

  // IP address validation
  static String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return CkString.requiredField;
    }
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    if (!ipRegex.hasMatch(value)) {
      return CkString.invalidIP;
    }
    return null;
  }
}
