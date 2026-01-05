import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove everything except digits
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String newText = '';
    int selectionIndex = newValue.selection.end;

    // Format as xxx-xxx-xxxx
    if (digits.length >= 1) {
      newText += digits.substring(0, digits.length < 3 ? digits.length : 3);
    }
    if (digits.length >= 4) {
      newText += '-${digits.substring(3, digits.length < 6 ? digits.length : 6)}';
    }
    if (digits.length >= 7) {
      newText += '-${digits.substring(6, digits.length < 10 ? digits.length : 10)}';
    }
    // Trim if longer than 12 chars (xxx-xxx-xxxx)
    if (newText.length > 12) {
      newText = newText.substring(0, 12);
    }
    // Adjust cursor position
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
