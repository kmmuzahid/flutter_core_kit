/*
 * @Author: Km Muzahid
 * @Date: 2026-01-20 12:57:02
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/dropdown/common_drop_down.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/text_field/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';

class CommonCountryPicker extends StatelessWidget {
  const CommonCountryPicker({
    super.key,
    this.hint = 'Country',
    this.prefix,
    required this.onChanged,
    this.initialValue,
    this.isRequired = false,
    this.fontStyle = FontStyle.normal,
    this.backgroundColor,
    this.borderColor,
    this.textStyle,
    this.isLoading = false,
    this.borderRadius = 8,
    this.enableInitalSelection = false,
    this.contentPadding,
    this.suffixIcon,
    this.nameBuilder,
    this.menuWidth,
    this.isSeparated = false,
    this.menuItemAlignment,
    this.itemPadding,
    this.menuElevation = 1.0,
    this.menuBorderColor,
    this.selectedItemBuilder,
    this.hintStyle,
    this.borderType = BorderType.outline,
    this.borderWidth = 1.2,
    this.dropDownType = DropDownType.menu,
    this.footer,
    this.menuMaxHeight,
  });
  final Widget? footer;
  final double? menuMaxHeight;
  final dynamic Function(DropDownNameBuilderProperty<String> property)?
  nameBuilder;
  final Widget? prefix;
  final String hint;
  final void Function(MapEntry<String, String>?) onChanged;
  final MapEntry<String, String>? initialValue;
  final bool isRequired;
  final FontStyle fontStyle;

  final Color? borderColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool isLoading;
  final double borderRadius;
  final bool enableInitalSelection;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;

  final Widget Function(String value)? selectedItemBuilder;
  final TextStyle? hintStyle;
  final BorderType borderType;
  final double borderWidth;
  final DropDownType dropDownType;
  final double? menuWidth;
  final bool isSeparated;
  final AlignmentGeometry? menuItemAlignment;
  final EdgeInsets? itemPadding;
  final double menuElevation;
  final Color? menuBorderColor;

  @override
  Widget build(BuildContext context) {
    final state = getStates().map((e) => MapEntry(e, e)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return CommonDropDown<MapEntry<String, String>>(
      key: const Key('Country_picker'),
      hint: hint,
      prefix: prefix,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      fontStyle: fontStyle,
      items: state,
      textStyle: textStyle,
      borderColor: borderColor,
      initalValue: initialValue,
      enableInitalSelection: enableInitalSelection,
      isRequired: isRequired,
      onChanged: onChanged,
      selectedItemBuilder: (value) {
        if (selectedItemBuilder != null) {
          return selectedItemBuilder!(value.value);
        }
        return CommonText(text: value.value);
      },
      dropDownType: dropDownType,
      menuWidth: menuWidth,
      isSeparated: isSeparated,
      menuItemAlignment: menuItemAlignment,
      itemPadding: itemPadding,
      menuElevation: menuElevation,
      menuBorderColor: menuBorderColor,
      footer: footer,
      menuMaxHeight: menuMaxHeight,
      nameBuilder: (states) {
        if (nameBuilder != null) {
          return nameBuilder?.call(
            DropDownNameBuilderProperty(
              item: states.item.value,
              isSelected: states.isSelected,
            ),
          );
        }
        return CommonText(text: states.item.value);
      },
    );
  }

  List<String> getStates() {
    final stateList = <String>[];

    for (final countryData in allStatesWithCities) {
      if (countryData is Map<String, dynamic>) {
        stateList.addAll(countryData.keys);
      }
    }

    return stateList;
  }
}
