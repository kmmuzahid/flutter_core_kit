import 'package:core_kit/initializer.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonDropDown<T> extends StatefulWidget {
  const CommonDropDown({
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.nameBuilder,
    this.isRequired = false,
    this.borderColor,
    this.backgroundColor,
    this.textStyle,
    this.isLoading = false,
    this.borderRadius = 12,
    this.prefix,
    this.initalValue,
    this.enableInitalSelection = true,
    super.key,
    this.fontStyle,
    this.contentPadding,
    this.selectedItemBuilder,
  });

  final String hint;
  final List<T> items;
  final Color? borderColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Function(T? value) onChanged;
  final dynamic Function(T value) nameBuilder;
  final bool isRequired;
  final bool isLoading;
  final double borderRadius;
  final Widget? prefix;
  final bool enableInitalSelection;
  final T? initalValue;
  final FontStyle? fontStyle;
  final EdgeInsets? contentPadding;
  final Widget Function(T value)? selectedItemBuilder;

  @override
  State<CommonDropDown<T>> createState() => _CommonDropDownState<T>();
}

class _CommonDropDownState<T> extends State<CommonDropDown<T>> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  T? _selectedItem;
  String? fontFamily = CoreKit.instance.fontFamily;
  late ThemeData theme;
  late List<T> _items;

  @override
  void initState() {
    theme = Theme.of(CoreKit.instance.scaffoldMessangerKey.currentContext!);
    super.initState();
    _items = widget.items;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _selectedItem = _getInitialSelection();

    if (_selectedItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_selectedItem);
      });
    }
  }

  T? _getInitialSelection() {
    if (widget.initalValue != null) {
      if (widget.initalValue is MapEntry) {
        return _items.firstWhere(
          (item) =>
              item is MapEntry && (item as MapEntry).key == (widget.initalValue as MapEntry).key,
          orElse: () => _items.isNotEmpty ? _items.first : widget.initalValue!,
        );
      } else {
        return _items.contains(widget.initalValue)
            ? widget.initalValue
            : (_items.isNotEmpty ? _items.first : null);
      }
    } else if (_items.isNotEmpty) {
      return _items.first;
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _getTextStyle(BuildContext context) {
    return widget.textStyle?.copyWith(fontFamily: fontFamily) ??
        TextStyle(fontFamily: fontFamily, fontSize: 16.sp, color: CoreKit.instance.outlineColor);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isLoading
        ? CoreKit.instance.primaryColor
        : (widget.borderColor ?? theme.inputDecorationTheme.border?.borderSide.color) ??
              CoreKit.instance.outlineColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        DropdownButtonFormField<T>(
          style: _getTextStyle(context),
          selectedItemBuilder: (context) {
            return _items.map((item) {
              return widget.selectedItemBuilder?.call(item) ??
                  CommonText(
                    text: widget.nameBuilder(item).toString(),
                    style: _getTextStyle(context),
                  );
            }).toList();
          },
          onSaved: widget.onChanged,
          validator: (value) {
            if (widget.isRequired &&
                (value == null || !_items.any((item) => _itemsEqual(item, value)))) {
              return '${widget.hint} is required';
            }
            return null;
          },
          initialValue: (widget.enableInitalSelection || widget.initalValue != null)
              ? _selectedItem
              : null,
          decoration: _buildInputDecoration(context, borderColor),
          hint: CommonText(
            text: widget.hint,
            style: _getTextStyle(
              context,
            ).copyWith(color: CoreKit.instance.outlineColor, fontStyle: widget.fontStyle),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: widget.backgroundColor ?? CoreKit.instance.surfaceBG,
          isExpanded: true,
          items: _items.map((item) {
            final name = widget.nameBuilder(item);
            return DropdownMenuItem<T>(
              value: item,
              child: name is Widget
                  ? name
                  : CommonText(text: name.toString(), style: _getTextStyle(context)),
            );
          }).toList(),
          onChanged: (T? newValue) {
            if (newValue == null) return;

            final matchingItem = widget.items.firstWhere(
              (item) => _itemsEqual(item, newValue),
              orElse: () => newValue,
            );

            setState(() {
              _selectedItem = matchingItem;
            });
            widget.onChanged(matchingItem);
          },
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return CustomPaint(
                  painter: _BorderLoaderPainter(
                    _controller.value,
                    borderColor,
                    widget.borderRadius,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, Color borderColor) {
    final backgroundColor = widget.backgroundColor ?? theme.inputDecorationTheme.fillColor;
    return InputDecoration(
      isDense: true,
      filled: backgroundColor != null,
      fillColor: backgroundColor,
      prefixIcon: widget.prefix != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: widget.prefix,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(),
      contentPadding:
          widget.contentPadding ?? EdgeInsets.only(left: 10.w, right: 2.w, top: 14.w, bottom: 14.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.borderRadius.r)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.w),
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.w),
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
      ),
    );
  }

  bool _itemsEqual(T a, T b) {
    if (a is MapEntry && b is MapEntry) {
      return a.key == b.key && a.value == b.value;
    }
    return a == b;
  }
}

class _BorderLoaderPainter extends CustomPainter {
  _BorderLoaderPainter(this.progress, this.color, this.borderRadius);
  final double progress;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;

    final dashWidth = 50.0.w;
    final dashSpace = 1.0.w;
    final totalLength = dashWidth + dashSpace;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = progress * metric.length;

      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += totalLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
