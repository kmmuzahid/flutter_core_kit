import 'package:core_kit/initizalizer.dart';
import 'package:flutter/material.dart';

/// A theme-aware radio group that accepts a Map of options where
/// - key: submitted value (what the form gets)
/// - value: label displayed to the user
///
/// Use CommonRadioFormField to integrate with Form and get the selected key on submit.
class CommonRadioGroup extends StatefulWidget {
  const CommonRadioGroup({
    required this.options,
    super.key,
    this.initialKey,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.horizontalScrollable = true,
    this.itemSpacing = 12.0,
    this.textStyle,
    this.padding,
    this.selectedColor,
    this.unSelectedColor,
    this.iconSize = 22.0,
  });

  /// Map of key -> label
  final Map<String, String> options;

  /// Initially selected key
  final String? initialKey;

  /// Called when user selects an option, with the selected key
  final ValueChanged<String>? onChanged;

  /// Layout direction (vertical or horizontal)
  final Axis direction;

  /// If true and direction is horizontal, makes the row scrollable
  final bool horizontalScrollable;

  /// Spacing between radio items
  final double itemSpacing;

  /// Optional text style for labels
  final TextStyle? textStyle;

  /// Optional padding around the whole widget
  final EdgeInsets? padding;

  /// Icon size for radio icons
  final double iconSize;

  final Color? selectedColor;
  final Color? unSelectedColor;

  @override
  State<CommonRadioGroup> createState() => _CommonRadioGroupState();
}

class _CommonRadioGroupState extends State<CommonRadioGroup> {
  late String? _selectedKey = widget.initialKey;

  void _select(String key) {
    if (_selectedKey == key) return;
    setState(() => _selectedKey = key);
    widget.onChanged?.call(key);
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.options.entries.toList();
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final selected = e.key == _selectedKey;
      children.add(
        _RadioItem(
          label: e.value,
          selected: selected,
          onTap: () => _select(e.key),
          textStyle: widget.textStyle,
          iconSize: widget.iconSize,
          selectedColor: widget.selectedColor,
          unSelectedColor: widget.unSelectedColor,
        ),
      );
      if (i != entries.length - 1) {
        children.add(
          SizedBox(
            width: widget.direction == Axis.horizontal ? widget.itemSpacing : 0,
            height: widget.direction == Axis.vertical ? widget.itemSpacing : 0,
          ),
        );
      }
    }

    Widget content;
    if (widget.direction == Axis.horizontal) {
      final row = Row(children: children);
      content = widget.horizontalScrollable
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
          : row;
    } else {
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }

    return Padding(padding: widget.padding ?? EdgeInsets.zero, child: content);
  }
}

class _RadioItem extends StatelessWidget {
  const _RadioItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    this.selectedColor,
    this.unSelectedColor,
    this.textStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final double iconSize;
  final Color? selectedColor;
  final Color? unSelectedColor;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? selectedColor ?? CoreKit.instance.primaryColor
        : unSelectedColor ?? CoreKit.instance.secondaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// FormField wrapper to integrate with Form and return the selected key on submit.
class CommonRadioFormField extends FormField<String> {
  CommonRadioFormField({
    required Map<String, String> options,
    super.key,
    String? initialKey,
    Axis direction = Axis.vertical,
    bool horizontalScrollable = true,
    double itemSpacing = 12.0,
    TextStyle? textStyle,
    EdgeInsets? padding,
    double iconSize = 22.0,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: initialKey,
         builder: (state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               CommonRadioGroup(
                 options: options,
                 initialKey: state.value,
                 direction: direction,
                 horizontalScrollable: horizontalScrollable,
                 itemSpacing: itemSpacing,
                 textStyle: textStyle,
                 padding: padding,
                 iconSize: iconSize,
                 onChanged: (key) => state.didChange(key),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4.0),
                   child: Text(
                     state.errorText ?? '',
                     style: CoreKit.instance.defaultTextStyle?.copyWith(color: Colors.red),
                   ),
                 ),
             ],
           );
         },
       );
}
