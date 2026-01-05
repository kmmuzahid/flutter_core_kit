import 'package:intl/intl.dart';

class CoreKitString {
  CoreKitString._(); // Prevent instantiation

  // ===== Generic =====
  static const String requiredField = 'This field is required';

  // ===== NID =====
  static const String nidRequired = 'National ID is required';
  static const String nidInvalid = 'National ID must be exactly 12 digits';

  // ===== Full Name =====
  static const String fullNameRequired = 'Full name is required';
  static const String fullNameInvalid = 'Please enter a valid full name';

  // ===== Email =====
  static const String invalidEmail = 'Please enter a valid email address';

  // ===== Phone =====
  static const String invalidPhone = 'Please enter a valid phone number (xxx-xxx-xxxx)';

  // ===== Password =====
  static const String invalidPassword =
      'Password must be at least 8 characters long, include one uppercase letter and one number';
  static const String passwordMismatch = 'Passwords do not match';

  // ===== Date =====
  static const String invalidDate = 'Please enter a valid date (YYYY-MM-DD)';

  // ===== URL =====
  static const String invalidURL = 'Please enter a valid URL';

  // ===== Number =====
  static const String invalidNumber = 'Please enter a valid number';

  // ===== Credit Card =====
  static const String invalidCreditCard = 'Please enter a valid 16-digit credit card number';

  // ===== Postal Code =====
  static const String invalidPostalCode = 'Please enter a valid postal code';

  // ===== Length =====
  static String minLengthError(int minLength) => 'Minimum length is $minLength characters';

  static String maxLengthError(int maxLength) => 'Maximum length is $maxLength characters';

  // ===== Date Range =====
  static String invalidDateRange(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat('yyyy-MM-dd');
    return 'Date must be between ${formatter.format(startDate)} and ${formatter.format(endDate)}';
  }

  // ===== Alpha Numeric =====
  static const String alphaNumericError = 'Only letters and numbers are allowed';

  // ===== Username =====
  static const String usernameError =
      'Username must be 3–15 characters and contain only letters, numbers, or underscores';

  // ===== Time =====
  static const String invalidTime = 'Please enter a valid time (HH:mm)';

  // ===== OTP =====
  static const String invalidOTP = 'OTP must be a 6-digit number';

  // ===== Currency =====
  static const String invalidCurrency = 'Please enter a valid amount (up to 2 decimal places)';

  // ===== IP Address =====
  static const String invalidIP = 'Please enter a valid IP address';
}
