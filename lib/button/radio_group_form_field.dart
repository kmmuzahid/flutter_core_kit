import 'package:flutter/material.dart';

class RadioGroupFormField<T> extends FormField<T> {
  RadioGroupFormField({
    required List<T> options,
    required String Function(T) labelBuilder,
    super.key,
    T? initialValue,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    Axis direction = Axis.vertical,
  }) : super(
         initialValue: initialValue ?? options.first,
         builder: (FormFieldState<T> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Flex(
                 direction: direction,
                 children:
                     options.map((T option) {
                       return RadioListTile<T>(
                         title: Text(labelBuilder(option)),
                         value: option,
                         groupValue: state.value,
                         onChanged: (val) => state.didChange(val),
                       );
                     }).toList(),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(left: 16.0),
                   child: Text(
                     state.errorText ?? '',
                     style: TextStyle(color: Theme.of(state.context).colorScheme.error, fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}
