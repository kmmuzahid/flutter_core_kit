import 'package:flutter/material.dart';

class CommonSelectableButton extends FormField<String> {
  CommonSelectableButton({
    required List<String> titles,
    super.key,
    double width = 100,
    String? initialValue,
    bool useWrap = false,
    ValueChanged<String>? onSelected,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(titles.isNotEmpty, 'Titles list must not be empty'),
       super(
         initialValue: initialValue ?? titles.first,
         builder: (FormFieldState<String> field) {
           final _SelectableButtonsState state = field as _SelectableButtonsState;

           final onPrimary = Theme.of(state.context).colorScheme.onPrimary;
           final primary = Theme.of(state.context).colorScheme.primary;

           final buttons =
               titles.map((title) {
                 final isSelected = title == field.value;

                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
                   child: SizedBox(
                     width: width,
                     child: ElevatedButton(
                       clipBehavior: Clip.antiAliasWithSaveLayer,
                       style: ElevatedButton.styleFrom(
                         side: BorderSide(color: primary),
                         foregroundColor: isSelected ? onPrimary : primary,
                         backgroundColor: isSelected ? primary : onPrimary,
                         textStyle: Theme.of(state.context).textTheme.labelLarge,
                       ),
                       onPressed: () {
                         field.didChange(title);
                         onSelected?.call(title);
                       },
                       child: Text(title, textAlign: TextAlign.center),
                     ),
                   ),
                 );
               }).toList();

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               useWrap
                   ? Wrap(spacing: 8, runSpacing: 8, children: buttons)
                   : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: buttons)),
               if (field.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                   child: Text(
                     field.errorText ?? '',
                     style: TextStyle(color: Theme.of(state.context).colorScheme.error),
                   ),
                 ),
             ],
           );
         },
       );

  @override
  FormFieldState<String> createState() => _SelectableButtonsState();
}

class _SelectableButtonsState extends FormFieldState<String> {
  double buttonWidth = 0;

  @override
  void initState() {
    super.initState();
  }
}
