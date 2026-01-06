/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 12:53:28
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/dropdown/common_drop_down.dart';
import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';

class CommonCityDropDown extends StatelessWidget {
  const CommonCityDropDown({
    required this.onChange,
    super.key,
    required this.selectedState,
    required this.selectedCountry,
    this.initalCity,
    this.backgroundColor,
    this.fontStyle,
    this.hint = 'City',
    this.prefix,
  });
  final String selectedState;
  final String selectedCountry;
  final String? initalCity;
  final FontStyle? fontStyle;
  final Color? backgroundColor;
  final Function(String value) onChange;
  final String hint;
  final Widget? prefix;
  @override
  Widget build(BuildContext context) {
    final city = getTheCities(
      country: selectedCountry ?? '',
      state: selectedState ?? '',
    ).map((e) => MapEntry(e, e)).toList()..sort((a, b) => a.key.compareTo(b.key));
    return CommonDropDown<MapEntry<String, String>>(
      hint: hint,
      prefix: prefix,
      fontStyle: fontStyle,
      items: city,
      textStyle: CoreKit.instance.defaultTextStyle,
      borderColor: CoreKit.instance.outlineColor,
      initalValue: initalCity != null
          ? city.firstWhere(
              (element) => element.key.trim().toLowerCase() == initalCity!.trim().toLowerCase(),
              orElse: () => city.first,
            )
          : null,
      enableInitalSelection: false,
      backgroundColor: backgroundColor ?? CoreKit.instance.surfaceBG,
      isRequired: true,
      onChanged: (states) {
        onChange(states?.value ?? '');
      },
      nameBuilder: (states) {
        return states.value;
      },
    );
  }

  List<String> getTheCities({required String country, required String state}) {
    if (country.isEmpty || state.isEmpty) {
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
        for (final stateEntry in stateData.entries) {
          final String stateName = stateEntry.key;
          if (stateName.trim().toLowerCase() == state.trim().toLowerCase()) {
            return stateEntry.value;
          }
        }
      }
    }
    return [];
  }
}
