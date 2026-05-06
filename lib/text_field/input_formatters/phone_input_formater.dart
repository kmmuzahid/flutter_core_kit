import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  int maxDigits;

  PhoneNumberFormatter({this.maxDigits = 10});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final textBeforeCursor = newValue.text.substring(0, cursorPos);

    final allDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final digitsBeforeCursor = textBeforeCursor.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );

    final capped = allDigits.length > maxDigits
        ? allDigits.substring(0, maxDigits)
        : allDigits;

    final buffer = StringBuffer();
    if (capped.isNotEmpty) {
      buffer.write(capped.substring(0, capped.length.clamp(0, 3)));
    }
    if (capped.length > 3) {
      buffer.write('-');
      buffer.write(capped.substring(3, capped.length.clamp(3, 6)));
    }
    if (capped.length > 6) {
      buffer.write('-');
      buffer.write(capped.substring(6));
    }

    final formatted = buffer.toString();

    final targetDigitCount = digitsBeforeCursor.length.clamp(0, capped.length);
    var newCursor = 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (digitsSeen == targetDigitCount) {
        newCursor = i;
        break;
      }
      if (formatted[i] != '-') digitsSeen++;
      newCursor = i + 1;
    }
    if (digitsSeen < targetDigitCount) newCursor = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}
