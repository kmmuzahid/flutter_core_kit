import 'package:core_kit/initializer.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/text_field/common_text_field.dart';
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
    this.borderRadius,
    this.prefix,
    this.initalValue,
    this.enableInitalSelection = true,
    super.key,
    this.fontStyle,
    this.contentPadding,
    this.selectedItemBuilder,
    this.hintStyle,
    this.borderType = BorderType.outline,
    this.borderWidth = 1.2,
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
  final double? borderRadius;
  final Widget? prefix;
  final bool enableInitalSelection;
  final T? initalValue;
  final FontStyle? fontStyle;
  final EdgeInsets? contentPadding;
  final Widget Function(T value)? selectedItemBuilder;
  final TextStyle? hintStyle;
  final BorderType borderType;
  final double borderWidth;

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
    theme = Theme.of(CoreKit.instance.navigatorKey.currentContext!);
    super.initState();
    _items = widget.items;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _selectedItem = _getInitialSelection();

    if (_selectedItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.enableInitalSelection) {
          widget.onChanged(_selectedItem);
        }
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

  
  Color hintColor() {
    return CoreKit.instance.theme.inputDecorationTheme.hintStyle?.color ??
        CoreKit.instance.outlineColor;
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
            style:
                widget.hintStyle ??
                _getTextStyle(context,
                  
                ).copyWith(
                  color: hintColor(),
                  fontSize:
                      CoreKit.instance.theme.inputDecorationTheme.hintStyle?.fontSize ?? 16.sp,
                  fontStyle: widget.fontStyle,
                ),
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
                    _buildBorder(color: borderColor),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  InputBorder _buildBorder({required Color color, double? width}) {
    if (widget.borderType == BorderType.underline) {
      return UnderlineInputBorder(
        borderRadius: _borderRadious(),
        borderSide: BorderSide(color: color, width: width ?? widget.borderWidth.w),
      );
    }
    return OutlineInputBorder(
      borderRadius: _borderRadious(),
      borderSide: BorderSide(color: color, width: width ?? widget.borderWidth.w),
    );
  }

  BorderRadius _borderRadious() {
    return widget.borderRadius == null
        ? CoreKit.instance.theme.inputDecorationTheme.border?.isOutline == true
              ? (CoreKit.instance.theme.inputDecorationTheme.border as OutlineInputBorder)
                    .borderRadius
              : BorderRadius.circular(12)
        : BorderRadius.circular(widget.borderRadius?.r ?? 0);
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
      border: _buildBorder(color: borderColor),
      enabledBorder: _buildBorder(color: borderColor),
      focusedBorder: _buildBorder(color: borderColor),
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
  final double progress;
  final Color color;
  final InputBorder inputBorder;

  _BorderLoaderPainter(this.progress, this.color, this.inputBorder);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Get correct path for ANY InputBorder type
    Path path = inputBorder.getInnerPath(rect);

    if (inputBorder is UnderlineInputBorder) {
      path = Path();
      path.moveTo(rect.bottomLeft.dx, rect.bottomLeft.dy);
      path.lineTo(rect.bottomRight.dx, rect.bottomRight.dy);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;

    const double dashWidthFactor = 0.02;
    const double dashSpaceFactor = 0.08;

    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      final dashWidth = metric.length * dashWidthFactor;
      final dashSpace = metric.length * dashSpaceFactor;
      final totalLength = dashWidth + dashSpace;

      double distance = progress * metric.length;

      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += totalLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.inputBorder != inputBorder;
  }
}
