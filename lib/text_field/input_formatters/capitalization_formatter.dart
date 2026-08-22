import 'package:flutter/services.dart';

/// Capitalizes the first letter after sentence-ending punctuation (. ! ?)
/// and the very first letter of the text, while collapsing multiple spaces
/// between sentences/words into a single space.
class SentenceCapitalizationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final textBeforeCursor = newValue.text.substring(0, cursorPos);

    final formatted = _format(newValue.text);
    final formattedBeforeCursor = _format(textBeforeCursor);

    final newCursor = formattedBeforeCursor.length.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  String _format(String input) {
    if (input.isEmpty) return input;

    // Collapse multiple spaces into a single space, but don't trim
    // leading/trailing spaces here so the user can still type a space
    // before continuing (trimming happens on save elsewhere).
    final result = input.replaceAll(RegExp(r' {2,}'), ' ');

    final buffer = StringBuffer();
    var capitalizeNext = true;
    for (var i = 0; i < result.length; i++) {
      final char = result[i];
      if (capitalizeNext && RegExp(r'[a-zA-Z]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        if (char == '.' || char == '!' || char == '?') {
          capitalizeNext = true;
        } else if (char != ' ') {
          capitalizeNext = false;
        }
      }
    }
    return buffer.toString();
  }
}

/// Capitalizes the first letter of every word (e.g. for full names).
class WordCapitalizationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final textBeforeCursor = newValue.text.substring(0, cursorPos);

    final formatted = _format(newValue.text);
    final formattedBeforeCursor = _format(textBeforeCursor);

    final newCursor = formattedBeforeCursor.length.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  String _format(String input) {
    if (input.isEmpty) return input;

    final buffer = StringBuffer();
    var capitalizeNext = true;
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (capitalizeNext && RegExp(r'[a-zA-Z]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        capitalizeNext = char == ' ' || char == '-' || char == "'";
      }
    }
    return buffer.toString();
  }
}

/// Formats text to be lowercase.
class LowercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

/// Formats any URL detected within the text to be lowercase, leaving other text unchanged.
class UrlLowercaseFormatter extends TextInputFormatter {
  static final RegExp _urlRegex = RegExp(
    r'(https?://[^\s]+|www\.[^\s]+|(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(?:/[^\s]*)?)',
    caseSensitive: false,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final formattedText = newValue.text.replaceAllMapped(
      _urlRegex,
      (match) => match.group(0)!.toLowerCase(),
    );

    if (formattedText == newValue.text) {
      return newValue;
    }

    return TextEditingValue(text: formattedText, selection: newValue.selection);
  }
}
