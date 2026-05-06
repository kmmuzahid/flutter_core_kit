import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  /// Maximum number of raw digits allowed (dashes are NOT counted)
  final int maxDigits;

  PhoneNumberFormatter({this.maxDigits = 10});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Count digits only before the cursor in the NEW (raw) value
    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final textBeforeCursor = newValue.text.substring(0, cursorPos);

    // Strip all non-digits from full text and from text-before-cursor
    final allDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final digitsBeforeCursor = textBeforeCursor.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );

    // Cap digits at maxDigits (dashes excluded — we're working on raw digits)
    final capped = allDigits.length > maxDigits
        ? allDigits.substring(0, maxDigits)
        : allDigits;

    // Re-format as xxx-xxx-xxxx (partial variants while typing)
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

    // Re-map cursor: count digits before cursor, then find that same digit
    // position in the newly formatted string
    final targetDigitCount = digitsBeforeCursor.length.clamp(0, capped.length);
    var newCursor = 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (digitsSeen == targetDigitCount) {
        newCursor = i;
        break;
      }
      if (formatted[i] != '-') digitsSeen++;
      newCursor = i + 1; // fallback: end of string
    }
    // If we've seen all target digits, cursor sits right after the last one
    if (digitsSeen < targetDigitCount) newCursor = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}
