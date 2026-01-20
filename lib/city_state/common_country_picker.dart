/*
 * @Author: Km Muzahid
 * @Date: 2026-01-20 12:57:02
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/dropdown/common_drop_down.dart';
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
  });

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
  @override
  Widget build(BuildContext context) {
    final state = getStates().map((e) => MapEntry(e, e)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return CommonDropDown<MapEntry<String, String>>(
      key: const Key('Country_picker'),
      hint: hint,
      prefix: prefix,
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
      nameBuilder: (states) {
        return states.value;
      },
    );
  }

  List<String> getStates() {
    List<String> stateList = [];

    for (final countryData in allStatesWithCities) {
      if (countryData is Map<String, dynamic>) {
        stateList.addAll(countryData.keys);
      }
    }

    return stateList;
  }
}
