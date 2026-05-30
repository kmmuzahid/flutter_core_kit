import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

/// A theme-aware radio group that accepts a Map of options where
/// - key: submitted value (what the form gets)
/// - value: label displayed to the user
class CkRadioGroup extends StatefulWidget {
  const CkRadioGroup({
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

  final Map<String, String> options;
  final String? initialKey;
  final ValueChanged<String>? onChanged;
  final Axis direction;
  final bool horizontalScrollable;
  final double itemSpacing;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double iconSize;
  final Color? selectedColor;
  final Color? unSelectedColor;

  @override
  State<CkRadioGroup> createState() => _CkRadioGroupState();
}

class _CkRadioGroupState extends State<CkRadioGroup> {
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
        children.add(SizedBox(
          width: widget.direction == Axis.horizontal ? widget.itemSpacing : 0,
          height: widget.direction == Axis.vertical ? widget.itemSpacing : 0,
        ));
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
        ? selectedColor ?? coreKitInstance.primaryColor
        : unSelectedColor ?? coreKitInstance.secondaryColor;

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
          Text(label, style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class CkRadioFormField extends FormField<String> {
  CkRadioFormField({
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
               CkRadioGroup(
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
                     style: coreKitInstance.defaultTextStyle?.copyWith(color: Colors.red),
                   ),
                 ),
             ],
           );
         },
       );
}


