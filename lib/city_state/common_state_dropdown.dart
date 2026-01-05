/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 14:19:18
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:core_kit/dropdown/common_drop_down.dart';
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
  });

  final String countryName;
  final Widget? prefix;
  final String hint;
  final void Function(MapEntry<String, String>?) onChanged;
  final MapEntry<String, String>? initialValue;
  final bool isRequired;
  final FontStyle fontStyle;

  @override
  Widget build(BuildContext context) {
    final state = getStates(country: countryName).map((e) => MapEntry(e, e)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return CommonDropDown<MapEntry<String, String>>(
      key: const Key('Location_united_states'),
      hint: hint,
      prefix: prefix,
      fontStyle: fontStyle,
      items: state,
      textStyle: CoreKit.instance.defaultTextStyle,
      borderColor: CoreKit.instance.outlineColor,
      initalValue: initialValue,
      enableInitalSelection: false,
      backgroundColor: CoreKit.instance.surfaceBG,
      isRequired: isRequired,
      onChanged: onChanged,
      nameBuilder: (states) {
        return states.value;
      },
    );
  }

  List<String> getStates({required String country}) {
    if (country.isEmpty) {
      return [];
    }
    List<Map<String, dynamic>>? selectedCountryData;

    for (final countryData in allStatesWithCities) {
      if (countryData is Map<String, dynamic> && countryData.containsKey(country)) {
        selectedCountryData = countryData[country];
        break;
      }
    }

    if (selectedCountryData != null) {
      for (final stateData in selectedCountryData) {
        return stateData.entries.map((e) => e.key).toList();
      }
    }
    return [];
  }
}
