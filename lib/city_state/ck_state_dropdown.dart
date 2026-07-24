/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 14:19:18
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/city_state/state_data.dart';
import 'package:core_kit/dropdown/ck_drop_down.dart';
import 'package:core_kit/text/ck_text.dart';
import 'package:core_kit/text_field/ck_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';

class CkStateDropDownItemProperty
    extends CkDropDownNameBuilderProperty<String> {
  final String stateName;
  final String? abbreviation;

  CkStateDropDownItemProperty({
    required this.stateName,
    this.abbreviation,
    required super.isSelected,
  }) : super(
          item: (abbreviation != null && abbreviation.isNotEmpty)
              ? abbreviation
              : stateName,
        );

  /// Full state name (e.g. `'California'`)
  String get name => stateName;

  /// Full state name (for key compatibility)
  String get key => stateName;

  /// Returns abbreviation if non-null and not empty, otherwise state name.
  String get value =>
      (abbreviation != null && abbreviation!.isNotEmpty) ? abbreviation! : stateName;
}

/// A dropdown widget for selecting states/provinces of a country.
///
/// Automatically provides full state name (`property.stateName`) and abbreviation (`property.abbreviation`)
/// to callbacks and builders via [CkStateDropDownItemProperty].
///
/// Supports passing either full state name or state abbreviation in [initialState].
///
/// Example:
/// ```dart
/// CkStateDropDown(
///   countryName: 'United States',
///   initialState: 'CA', // Accepts state name ('California') or abbreviation ('CA')
///   onChanged: (property) {
///     print(property?.stateName);    // California
///     print(property?.abbreviation); // CA
///   },
///   selectedItemBuilder: (property) => CkText(
///     text: property.stateName,
///   ),
///   nameBuilder: (property) => CkText(
///     text: '${property.stateName}${property.abbreviation != null ? " (${property.abbreviation})" : ""}',
///   ),
/// )
/// ```
class CkStateDropDown extends StatelessWidget {
  const CkStateDropDown({
    super.key,
    this.hint = 'State',
    this.prefix,
    required this.countryName,
    required this.onChanged,
    this.initialValue,
    this.initialState,
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
    this.customAbbreviationMap,
    this.showAbbreviationInMenu = false,

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

  final dynamic Function(CkStateDropDownItemProperty property)? nameBuilder;

  final String countryName;
  final Widget? prefix;
  final String hint;

  /// Callback when state selection changes.
  final void Function(CkStateDropDownItemProperty?) onChanged;
  final MapEntry<String, String>? initialValue;

  /// Optional initial state specified as state name or abbreviation (e.g. `'California'` or `'CA'`).
  /// Takes precedence over [initialValue] when provided.
  final String? initialState;

  final bool isRequired;
  final FontStyle fontStyle;

  /// Optional custom mapping for state abbreviations (e.g. `{'California': 'CA'}`).
  final Map<String, String>? customAbbreviationMap;

  /// Whether to show the abbreviation in the menu items (e.g. "California (CA)").
  final bool showAbbreviationInMenu;

  final Color? borderColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool isLoading;
  final double borderRadius;
  final bool enableInitalSelection;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;

  final Widget Function(CkStateDropDownItemProperty property)?
  selectedItemBuilder;
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

  /// Helper to get the abbreviation for a given state name and country.
  static String? getStateAbbreviation(
    String country,
    String stateName, [
    Map<String, String>? customMap,
  ]) {
    if (customMap != null) {
      for (final entry in customMap.entries) {
        if (entry.key.trim().toLowerCase() == stateName.trim().toLowerCase()) {
          return entry.value;
        }
      }
    }
    return StateAbbreviations.getAbbreviation(country, stateName);
  }

  @override
  Widget build(BuildContext context) {
    final state = getStates(country: countryName).map((e) {
      final abbr = getStateAbbreviation(countryName, e, customAbbreviationMap);
      return MapEntry(e, abbr ?? e);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final searchKey = initialState ?? initialValue?.key;
    final searchValue = initialState ?? initialValue?.value;

    MapEntry<String, String>? resolvedInitialValue;
    if ((searchKey != null || searchValue != null) && state.isNotEmpty) {
      final sKey = (searchKey ?? '').trim().toLowerCase();
      final sVal = (searchValue ?? '').trim().toLowerCase();

      try {
        resolvedInitialValue = state.firstWhere(
          (element) {
            final eKey = element.key.trim().toLowerCase();
            final eVal = element.value.trim().toLowerCase();
            return (sKey.isNotEmpty && (eKey == sKey || eVal == sKey)) ||
                (sVal.isNotEmpty && (eKey == sVal || eVal == sVal));
          },
          orElse: () => initialValue ?? MapEntry(searchKey ?? '', searchValue ?? ''),
        );
      } catch (_) {
        resolvedInitialValue = initialValue;
      }
    }

    return CkDropDown<MapEntry<String, String>>(
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
      initalValue: resolvedInitialValue,
      enableInitalSelection: enableInitalSelection,
      isRequired: isRequired,
      onChanged: (entry) {
        if (entry == null) {
          onChanged(null);
          return;
        }
        final stateName = entry.key;
        final abbr = entry.value != entry.key
            ? entry.value
            : getStateAbbreviation(countryName, stateName, customAbbreviationMap);
        onChanged(
          CkStateDropDownItemProperty(
            stateName: stateName,
            abbreviation: abbr,
            isSelected: true,
          ),
        );
      },
      selectedItemBuilder: (value) {
        final stateName = value.key;
        final abbr = value.value != value.key
            ? value.value
            : getStateAbbreviation(countryName, stateName, customAbbreviationMap);
        final prop = CkStateDropDownItemProperty(
          stateName: stateName,
          abbreviation: abbr,
          isSelected: true,
        );

        if (selectedItemBuilder != null) {
          return selectedItemBuilder!(prop);
        }
        return CkText(text: stateName);
      },
      dropDownType: dropDownType,
      menuWidth: menuWidth,
      isSeparated: isSeparated,
      menuItemAlignment: menuItemAlignment,
      itemPadding: itemPadding,
      menuElevation: menuElevation,
      menuBorderColor: menuBorderColor,
      nameBuilder: (states) {
        final stateName = states.item.key;
        final abbr = states.item.value != states.item.key
            ? states.item.value
            : getStateAbbreviation(countryName, stateName, customAbbreviationMap);
        final displayText = (showAbbreviationInMenu && abbr != null && abbr != stateName)
            ? '$stateName ($abbr)'
            : stateName;

        final prop = CkStateDropDownItemProperty(
          stateName: stateName,
          abbreviation: abbr,
          isSelected: states.isSelected,
        );

        if (nameBuilder != null) {
          return nameBuilder?.call(prop);
        }
        return CkText(text: displayText);
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

