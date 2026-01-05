import 'package:core_kit/core_kit.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoreUtils {
  static late Size deviceSize;

  static RepaintBoundary divider() => RepaintBoundary(
    child: Divider(color: CoreKit.instance.outlineColor, thickness: 1.w),
  );

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    return DateTime.tryParse(dateString);
  }

  static DateTime subtractYears(DateTime date, int yearsToSubtract) {
    // Handle edge case for leap year (Feb 29 to non-leap year)
    final int newYear = date.year - yearsToSubtract;
    final int newMonth = date.month;
    final int newDay = date.day;

    // Check if the resulting date would be invalid (e.g., Feb 29 to non-leap year)
    // Dart automatically corrects this to Feb 28 if the new year is not a leap year
    DateTime newDate;
    try {
      newDate = DateTime(
        newYear,
        newMonth,
        newDay,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
    } catch (e) {
      // Fallback: if invalid date, set day to last valid day of the month
      newDate = DateTime(
        newYear,
        newMonth + 1,
        0,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
    }
    return newDate;
  }

  static String formatDateTimeToHms(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final hours = localDate.hour.toString().padLeft(2, '0');
    final minutes = localDate.minute.toString().padLeft(2, '0');
    final seconds = localDate.second.toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  static String formatDurationToHms(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time.toLocal()); // 'jm' = e.g., 8:00 PM
  }

  static String formatDateTimeWithSHortMonth(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final hours = (localDate.hour % 12).toString().padLeft(2, '0');
    final minutes = localDate.minute.toString().padLeft(2, '0');
    final amPm = localDate.hour < 12 ? 'AM' : 'PM';

    final shortMonth = DateFormat('MMM').format(localDate);
    final day = DateFormat('d').format(localDate);

    final shortDay = DateFormat('E').format(localDate).substring(0, 3);
    return '$day $shortMonth $shortDay $hours:$minutes $amPm';
  }

  static String formatDateToShortMonth(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    const List<String> monthAbbr = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String day = localDate.day.toString().padLeft(2, '0');
    final String month = monthAbbr[localDate.month - 1];
    final String year = localDate.year.toString();

    return '$day $month $year';
  }

  static String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('MMM dd, h:mm a');
    return dateFormat.format(dateTime.toLocal());
  }

  static String formatDouble(double value) {
    final double rounded = double.parse(value.toStringAsFixed(1));
    if (rounded == rounded.toInt()) {
      return rounded.toInt().toString();
    } else {
      return rounded.toStringAsFixed(1);
    }
  }
}
