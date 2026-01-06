import 'package:core_kit/initizalizer.dart';
import 'package:core_kit/utils/app_log.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

ThemeData get getTheme => Theme.of(CoreKit.instance.navigatorKey.currentContext!);

extension StringCasingExtension on String {
  String capitalizeEachWord() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

extension EnumDisplayName on Enum {
  String get displayName {
    final raw = name;
    final spaced = raw.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '${match.group(0)}');

    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

extension StringExtensions on String {
  String get newLine => '$this\n';

  ///capitalize each word in the line
  String get capitalize {
    if (isEmpty) return this;
    return split(' ').map((e) => e.capitalizeFirst).join(' ');
  }

  ///capitalize first letter of the string
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension View on num {
  Widget get height => SizedBox(height: toDouble().h);

  Widget get width => SizedBox(width: toDouble().w);
}

// All Alignments Extensions

extension Alignments on Widget {
  Widget get start => Align(alignment: Alignment.centerLeft, child: this);

  Widget get end => Align(alignment: Alignment.centerRight, child: this);

  Widget get center => Align(child: this);
}

// All Alignments Time Formatter Extensions
extension TimeFormater on DateTime {
  String get time => DateFormat('h:mm a').format(this);

  String get date => DateFormat('dd-MM-yyyy').format(this);

  String get dayName => DateFormat('E').format(this);

  String get checkTime {
    final DateTime currentDateTime = DateTime.now();

    final Duration difference = currentDateTime.difference(this);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return ('${difference.inMinutes} minutes ago');
      } else {
        return ('${difference.inHours} hours ago');
      }
    } else {
      final createdAtTime = toIso8601String().split('.')[0];
      final date = createdAtTime.split('T')[0];
      final time = createdAtTime.split('T')[1];
      return '$date at $time';
    }
  }
}

extension AsyncTryCatch on Function() {
  Future<void> tryCatch() async {
    try {
      await this();
    } catch (e, stackTrace) {
      AppLogger.error(stackTrace.toString(), tag: 'Global Try Catch');
    }
  }
}

extension WidgetPaddingX on Widget {
  Widget paddingAll(double padding) => Padding(padding: EdgeInsets.all(padding), child: this);

  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(top: top.w, left: left.w, right: right.w, bottom: bottom.w),
    child: this,
  );

  Widget get paddingZero => Padding(padding: EdgeInsets.zero, child: this);
}

/// Add margin property to widget
extension WidgetMarginX on Widget {
  Widget marginAll(double margin) => Container(margin: EdgeInsets.all(margin), child: this);

  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) => Container(
    margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Container(
    margin: EdgeInsets.only(top: top.w, left: left.w, right: right.w, bottom: bottom.w),
    child: this,
  );

  Widget get marginZero => Container(margin: EdgeInsets.zero, child: this);
}

/// Allows you to insert widgets inside a CustomScrollView
extension WidgetSliverBoxX on Widget {
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}

extension XFileToMultipart on XFile {
  Future<dio.MultipartFile> toMultipart() {
    return dio.MultipartFile.fromFile(
      path,
      filename: name,
      contentType: MediaType.parse(_getMimeTypeFromXFile(this) ?? ''),
    );
  }
}

extension ListXFileToMultipart on List<XFile> {
  Future<List<dio.MultipartFile>> toMultipart() async {
    return await Future.wait(map((e) => e.toMultipart()));
  }
}

String? _getMimeTypeFromXFile(XFile file) {
  // Get the file extension from the file path
  String extension = file.path.split('.').last.toLowerCase();

  // Map the extension to MIME type
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';
    case 'pdf':
      return 'application/pdf';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'doc':
    case 'docx':
      return 'application/msword';
    case 'xls':
    case 'xlsx':
      return 'application/vnd.ms-excel';
    default:
      return 'application/octet-stream'; // Default MIME type for unknown extensions
  }
}

extension TimeOfDayParser on String {
  /// Parses a time string that was created with `timeOfDay.format(context)`
  /// Supports both 12-hour (e.g. "2:30 PM") and 24-hour (e.g. "14:30") formats
  TimeOfDay toTimeOfDay(BuildContext context) {
    if (isEmpty) {
      throw FormatException('Time string is empty');
    }

    final localizations = MaterialLocalizations.of(context);
    final is24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;

    final trimmed = trim();

    if (is24HourFormat) {
      // 24-hour format: "14:30" or "09:05"
      final regExp = RegExp(r'^(\d{1,2}):(\d{2})$');
      final match = regExp.firstMatch(trimmed);
      if (match == null) {
        throw FormatException('Invalid 24-hour time format: $trimmed');
      }
      return TimeOfDay(hour: int.parse(match.group(1)!), minute: int.parse(match.group(2)!));
    } else {
      // 12-hour format: "2:30 PM", "11:45 AM", etc.
      final regExp = RegExp(r'^(\d{1,2}):(\d{2})\s?([AaPp][Mm])$');
      final match = regExp.firstMatch(trimmed);
      if (match == null) {
        throw FormatException('Invalid 12-hour time format: $trimmed');
      }

      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      if (hour == 12) {
        hour = period == 'AM' ? 0 : 12;
      } else if (period == 'PM') {
        hour += 12;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }
  }
}

extension NullableTimeOfDayParser on String? {
  /// Safe version that returns null if string is null or invalid
  TimeOfDay? tryToTimeOfDay(BuildContext context) {
    if (this == null || this!.trim().isEmpty) return null;
    try {
      return this!.toTimeOfDay(context);
    } catch (_) {
      return null;
    }
  }
}

/// Context-FREE extensions – work anywhere!
extension TimeOfDayString on TimeOfDay {
  /// Returns "14:30" – always 24-hour, zero-padded (perfect for storage, sorting, JSON)
  String toHHmm() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Returns "2:30 PM" style – 12-hour with AM/PM (you choose the style)
  String to12HourString({bool includeSpace = true}) {
    final h = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final space = includeSpace ? ' ' : '';
    return '$h:${minute.toString().padLeft(2, '0')}$space$period';
  }
}

extension StringToTimeOfDay on String {
  /// "14:30" → TimeOfDay (24-hour format) – most common & safest
  TimeOfDay toTimeOfDay24() {
    final parts = trim().split(':');
    if (parts.length < 2) throw FormatException('Invalid time format: $this');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1].substring(0, 2)));
  }

  /// "2:30 PM", "02:30pm", "2:30PM" → TimeOfDay (12-hour format)
  TimeOfDay toTimeOfDay12() {
    final cleaned = trim().replaceAll(' ', '');
    final regExp = RegExp(r'^(\d{1,2}):(\d{2})(AM|PM|am|pm)$', caseSensitive: false);
    final match = regExp.firstMatch(cleaned);
    if (match == null) {
      throw FormatException('Invalid 12-hour time format: $this');
    }

    int h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (h == 12) h = 0;
    if (period == 'PM') h += 12;

    return TimeOfDay(hour: h, minute: m);
  }

  /// Smart detection: tries 24h first, then 12h
  TimeOfDay toTimeOfDayAuto() {
    try {
      return toTimeOfDay24();
    } on FormatException {
      return toTimeOfDay12();
    }
  }
}
