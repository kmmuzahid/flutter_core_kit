/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 12:53:28
 * @Email: km.muzahid@gmail.com
 */

import 'package:core_kit/dropdown/ck_drop_down.dart';
import 'package:core_kit/text/ck_text.dart';
import 'package:core_kit/text_field/ck_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';

class CkCityDropDown extends StatelessWidget {
  const CkCityDropDown({
    required this.onChange,
    super.key,
    required this.selectedState,
    required this.selectedCountry,
    this.initalCity,
    this.backgroundColor,
    this.fontStyle,
    this.hint = 'City',
    this.prefix,
    this.borderColor,
    this.textStyle,
    this.isRequired = false,
    this.isLoading = false,
    this.borderRadius = 8,
    this.enableInitalSelection = false,
    this.contentPadding,
    this.suffixIcon,
    this.menuBackgroundColor,
    this.nameBuilder,

    this.menuWidth,
    this.isSeparated = false,
    this.menuItemAlignment,
    this.itemPadding,
    this.menuElevation = 1.0,
    this.menuBorderColor,
    this.selectedItemBuilder,
    this.hintStyle,
    this.borderType = CkBorderType.outline,
    this.borderWidth = 1.2,
    this.dropDownType = CkDropDownType.menu,
    this.menuMaxHeight,
  });
  final String selectedState;
  final String selectedCountry;
  final String? initalCity;
  final FontStyle? fontStyle;
  final Color? backgroundColor;
  final Function(String value) onChange;
  final String hint;
  final Widget? prefix;
  final Color? borderColor;
  final TextStyle? textStyle;
  final bool isRequired;
  final bool isLoading;
  final double borderRadius;
  final bool enableInitalSelection;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;
  final Color? menuBackgroundColor;
  final dynamic Function(CkDropDownNameBuilderProperty<String> property)?
  nameBuilder;

  final Widget Function(String value)? selectedItemBuilder;
  final TextStyle? hintStyle;
  final CkBorderType borderType;
  final double borderWidth;
  final CkDropDownType dropDownType;
  final double? menuWidth;
  final bool isSeparated;
  final AlignmentGeometry? menuItemAlignment;
  final EdgeInsets? itemPadding;
  final double menuElevation;
  final Color? menuBorderColor;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    final city =
        getTheCities(
            country: selectedCountry,
            state: selectedState,
          ).map((e) => MapEntry(e, e)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return CkDropDown<MapEntry<String, String>>(
      hint: hint,
      prefix: prefix,
      suffixIcon: suffixIcon,
      menuBackgroundColor: menuBackgroundColor,
      fontStyle: fontStyle,
      contentPadding: contentPadding,
      items: city,
      textStyle: textStyle,
      isLoading: isLoading,
      borderRadius: borderRadius,
      menuMaxHeight: menuMaxHeight,
      borderColor: borderColor,
      initalValue: (initalCity != null && city.isNotEmpty)
          ? city.firstWhere(
              (element) =>
                  element.key.trim().toLowerCase() ==
                  initalCity!.trim().toLowerCase(),
              orElse: () => city.first,
            )
          : null,
      enableInitalSelection: enableInitalSelection,
      backgroundColor: backgroundColor,
      isRequired: isRequired,
      onChanged: (states) {
        onChange(states?.value ?? '');
      },

      selectedItemBuilder: (value) {
        if (selectedItemBuilder != null) {
          return selectedItemBuilder!(value.value);
        }
        return CkText(text: value.value);
      },
      dropDownType: dropDownType,
      menuWidth: menuWidth,
      isSeparated: isSeparated,
      menuItemAlignment: menuItemAlignment,
      itemPadding: itemPadding,
      menuElevation: menuElevation,
      menuBorderColor: menuBorderColor,
      nameBuilder: (state) {
        if (nameBuilder != null) {
          return nameBuilder?.call(
            CkDropDownNameBuilderProperty(
              item: state.item.value,
              isSelected: state.isSelected,
            ),
          );
        }
        return CkText(text: state.item.value);
      },
    );
  }

  List<String> getTheCities({required String country, required String state}) {
    if (country.isEmpty || state.isEmpty) {
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

    if (selectedCountryData != null) {
      for (final stateData in selectedCountryData) {
        for (final stateEntry in stateData.entries) {
          final stateName = stateEntry.key;
          if (stateName.trim().toLowerCase() == state.trim().toLowerCase()) {
            return stateEntry.value;
          }
        }
      }
    }
    return [];
  }
}

