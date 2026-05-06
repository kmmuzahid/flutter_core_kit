/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 14:19:18
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/dropdown/common_drop_down.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/text_field/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';

class CommonStateDropdown extends StatelessWidget {
  const CommonStateDropdown({
    super.key,
    this.hint = 'State',
    this.prefix,
    required this.countryName,
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
    this.menuMaxHeight,
  });
  final dynamic Function(DropDownNameBuilderProperty<String> property)?
  nameBuilder;

  final String countryName;
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
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    final state =
        getStates(country: countryName).map((e) => MapEntry(e, e)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return CommonDropDown<MapEntry<String, String>>(
      key: const Key('Location_united_states'),
      hint: hint,
      prefix: prefix,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      isLoading: isLoading,
      menuMaxHeight: menuMaxHeight,
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

  List<String> getStates({required String country}) {
    if (country.isEmpty) {
      return [];
    }
    List<Map<String, dynamic>>? selectedCountryData;

    for (final countryData in allStatesWithCities) {
      if (countryData is Map<String, dynamic> &&
          countryData.containsKey(country)) {
        selectedCountryData = countryData[country];
        break;
      }
    }

    final stateList = <String>[];

    if (selectedCountryData != null) {
      for (final stateData in selectedCountryData) {
        stateList.addAll(stateData.entries.map((e) => e.key).toList());
      }
    }
    return stateList;
  }
}
