import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  /// Maximum number of raw digits allowed (dashes excluded from count)
  final int maxDigits;

  PhoneNumberFormatter({this.maxDigits = 10});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything that is not a digit
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Cap at maxDigits — dashes are NOT counted
    final capped =
        digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;

    // Re-format as xxx-xxx-xxxx (or shorter variants while typing)
    var formatted = '';
    if (capped.isNotEmpty) {
      formatted += capped.substring(0, capped.length < 3 ? capped.length : 3);
    }
    if (capped.length > 3) {
      formatted +=
          '-${capped.substring(3, capped.length < 6 ? capped.length : 6)}';
    }
    if (capped.length > 6) {
      formatted += '-${capped.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
