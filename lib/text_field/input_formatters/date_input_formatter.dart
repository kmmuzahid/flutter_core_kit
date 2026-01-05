import 'package:flutter/services.dart';

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty or shorter than old value (backspace/delete)
    if (newValue.text.isEmpty || newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // If no digits, return empty
    if (digits.isEmpty) return const TextEditingValue();

    String formatted = '';

    // Handle year (first 4 digits)
    if (digits.length <= 4) {
      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
    
    // We have at least 4 digits (year)
    String year = digits.substring(0, 4);
    formatted = year;
    digits = digits.substring(4);

    // Handle month (next 1-2 digits)
    if (digits.isNotEmpty) {
      // If we have more than 2 digits, take first 2 for month
      String monthStr = digits.length > 2 ? digits.substring(0, 2) : digits;

      // Parse month, default to 1 if invalid
      int month = int.tryParse(monthStr) ?? 1;

      // If we have 2 digits, validate month
      if (monthStr.length == 2) {
        if (month < 1) month = 1;
        if (month > 12) month = 12;
        formatted += '-${month.toString().padLeft(2, '0')}';

        // Remove processed month digits
        digits = digits.substring(2);

        // Handle day if we have digits left
        if (digits.isNotEmpty) {
          int maxDay = _getDaysInMonth(month, int.parse(year));
          String dayStr = digits.length > 2 ? digits.substring(0, 2) : digits;
          int day = int.tryParse(dayStr) ?? 1;

          if (dayStr.length == 2) {
            if (day < 1) day = 1;
            if (day > maxDay) day = maxDay;
            formatted += '-${day.toString().padLeft(2, '0')}';
          } else {
            // Single digit day
            formatted += '-$dayStr';
          }
        }
      } else {
        // Single digit month, just append without validation
        formatted += '-$monthStr';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      // February
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29; // Leap year
      }
      return 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }
}
