import 'package:core_kit/text_field/common_text_field.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/utils/app_utils.dart';
import 'package:flutter/material.dart';

import 'validation_type.dart';

class CommonDateInputTextField extends StatefulWidget {
  CommonDateInputTextField({
    super.key,
    this.onSave,
    this.prefixIcon,
    this.paddingHorizontal = 16,
    this.paddingVertical = 14,
    this.borderRadius = 10,
    this.onChanged,
    this.suffix,
    this.validation,
    this.borderColor,
    this.backgroundColor,
    this.initialValue,
    this.isReadOnly = false,
    this.hints,
    this.minDate,
    this.maxDate,
    this.showValidationMessage,
    this.isValidationRequired,
  }) : assert(
         minDate == null ||
             maxDate == null ||
             minDate.isBefore(maxDate) ||
             minDate.isAtSameMomentAs(maxDate),
         'minDate must be before or equal to maxDate',
       );

  /// The earliest date the user is permitted to pick.
  final DateTime? minDate;

  /// The latest date the user is permitted to pick.
  final DateTime? maxDate;
  final double paddingHorizontal;
  final double paddingVertical;
  final double borderRadius;
  final Function(DateTime? date)? onSave;
  final Widget? suffix;
  final Function(DateTime? date)? onChanged;
  final String? Function(String? value)? validation;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final bool isReadOnly;
  final String? hints;
  final String? initialValue;
  final bool? showValidationMessage;
  final bool? isValidationRequired;

  @override
  State<CommonDateInputTextField> createState() => _CommonDateInputTextFieldState();
}

class _CommonDateInputTextFieldState extends State<CommonDateInputTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  DateTime _calculateMinDate() {
    if (widget.minDate != null) return widget.minDate!;
    return DateTime(1900);
  }

  DateTime _calculateMaxDate() {
    if (widget.maxDate != null) return widget.maxDate!;
    return DateTime(2100);
  }

  DateTime _calculateInitialDate() {
    final now = DateTime.now();
    if (widget.minDate != null && widget.minDate!.isAfter(now)) {
      return widget.minDate!;
    }
    if (widget.maxDate != null && widget.maxDate!.isBefore(now)) {
      return widget.maxDate!;
    }
    return now;
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = _calculateMinDate();
    final lastDate = _calculateMaxDate();
    final initialDate = _calculateInitialDate();

    // Ensure the initial date is within the allowed range
    final clampedInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : (initialDate.isAfter(lastDate) ? lastDate : initialDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: clampedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      _controller.text = '${picked.toLocal()}'.split(' ')[0];
      widget.onChanged?.call(picked.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      showValidationMessage: widget.showValidationMessage ?? true,
      isReadOnly: widget.isReadOnly,
      controller: _controller,
      paddingHorizontal: widget.paddingHorizontal,
      paddingVertical: widget.paddingVertical,
      borderRadius: widget.borderRadius,
      onChanged: (value) {
        widget.onChanged?.call(CoreUtils.parseDate(value));
      },

      hintText: widget.hints ?? 'YYYY-MM-DD',
      onSaved: (value, _) {
        if (widget.onSave == null) return;
        widget.onSave!(CoreUtils.parseDate(value));
      },
      suffixIcon: GestureDetector(
        onTap: () {
          if (widget.isReadOnly) return;
          _openDatePicker(context);
        },
        child: widget.suffix ?? const Icon(Icons.calendar_month_outlined),
      ),
      validationType: widget.isValidationRequired ?? false
          ? ValidationType.validateDate
          : ValidationType.notRequired,
      prefixIcon: widget.prefixIcon,
      validation: widget.validation,
      borderColor: widget.borderColor,
      backgroundColor: widget.backgroundColor,
    );
  }
}
