/*
 * @Author: Km Muzahid
 * @Date: 2026-01-20 12:57:02
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/dropdown/ck_drop_down.dart';
import 'package:core_kit/text/ck_text.dart';
import 'package:core_kit/text_field/ck_text_field.dart';
import 'package:core_kit/utils/ck_screen_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_country_state/complied_cities.dart';
import 'package:intl_phone_field_v2/countries.dart' as intl_countries;

class CkCountryPickerNameBuilderProperty<T>
    extends CkDropDownNameBuilderProperty<T> {
  final String _flagEmoji;
  final String countryCode;

  CkCountryPickerNameBuilderProperty({
    required super.item,
    required super.isSelected,
    required String flag,
    required this.countryCode,
  }) : _flagEmoji = flag;

  Widget flag({double? width}) {
    if (countryCode.isEmpty) return const SizedBox.shrink();
    final targetWidth = width ?? 40.w;
    if (kIsWeb) {
      return Image.asset(
        'assets/flags/${countryCode.toLowerCase()}.png',
        package: 'intl_phone_field_v2',
        width: targetWidth,
      );
    }
    return Text(_flagEmoji, style: TextStyle(fontSize: targetWidth * 0.75));
  }
}

class CkCountryPicker extends StatelessWidget {
  const CkCountryPicker({
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
    this.disabled = false,
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
    this.borderType = CkBorderType.outline,
    this.borderWidth = 1.2,
    this.dropDownType = CkDropDownType.menu,
    this.footer,
    this.menuMaxHeight,
    this.enableFlag = true,
  });
  final Widget? footer;
  final double? menuMaxHeight;
  final dynamic Function(CkCountryPickerNameBuilderProperty<String> property)?
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

  /// When [disabled] is `true` the picker cannot be opened.
  /// Only the initial value will be visible; the user cannot change it.
  final bool disabled;

  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;

  final Widget Function(CkCountryPickerNameBuilderProperty property)?
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
  final bool enableFlag;

  @override
  Widget build(BuildContext context) {
    final state = getStates().map((e) => MapEntry(e, e)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return CkDropDown<MapEntry<String, String>>(
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
      disabled: disabled,
      isRequired: isRequired,
      onChanged: onChanged,
      selectedItemBuilder: (value) {
        final country = _findCountry(value.value);
        final flag = country?.flag ?? '';
        final countryCode = country?.code ?? '';
        if (selectedItemBuilder != null) {
          return selectedItemBuilder!(
            CkCountryPickerNameBuilderProperty(
              item: value.value,
              isSelected: true,
              flag: flag,
              countryCode: countryCode,
            ),
          );
        }
        if (enableFlag && country != null && countryCode.isNotEmpty) {
          final prop = CkCountryPickerNameBuilderProperty(
            item: value.value,
            isSelected: true,
            flag: flag,
            countryCode: countryCode,
          );
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              prop.flag(),
              const SizedBox(width: 8),
              Expanded(child: CkText(text: value.value)),
            ],
          );
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
      footer: footer,
      menuMaxHeight: menuMaxHeight,
      nameBuilder: (states) {
        final country = _findCountry(states.item.value);
        final flag = country?.flag ?? '';
        final countryCode = country?.code ?? '';
        if (nameBuilder != null) {
          return nameBuilder!.call(
            CkCountryPickerNameBuilderProperty(
              item: states.item.value,
              isSelected: states.isSelected,
              flag: flag,
              countryCode: countryCode,
            ),
          );
        }
        if (enableFlag && country != null && countryCode.isNotEmpty) {
          final prop = CkCountryPickerNameBuilderProperty(
            item: states.item.value,
            isSelected: states.isSelected,
            flag: flag,
            countryCode: countryCode,
          );
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              prop.flag(),
              const SizedBox(width: 8),
              Expanded(child: CkText(text: states.item.value)),
            ],
          );
        }
        return CkText(text: states.item.value);
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

  intl_countries.Country? _findCountry(String countryName) {
    try {
      return intl_countries.countries.firstWhere(
        (c) => c.name.toLowerCase() == countryName.toLowerCase(),
        orElse: () => intl_countries.countries.firstWhere(
          (c) =>
              countryName.toLowerCase().contains(c.name.toLowerCase()) ||
              c.name.toLowerCase().contains(countryName.toLowerCase()),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
