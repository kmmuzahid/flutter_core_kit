import 'package:core_kit/initializer.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'validation_type.dart';

class CommonMultilineTextField extends StatefulWidget {
  const CommonMultilineTextField({
    required this.validationType,
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.prefixText,
    this.paddingHorizontal = 16,
    this.paddingVertical = 14,
    this.borderRadius = 12,
    this.onSaved,
    this.onChanged,
    this.borderColor,
    this.onTap,
    this.suffixIcon,
    this.isReadOnly = false,
    this.initialText,
    this.showActionButton = false,
    this.actionButtonIcon,
    this.originalPassword,
    this.validation,
    this.backgroundColor,
    this.borderWidth = 1.2,
    this.showValidationMessage = true,
    this.textAlign = TextAlign.left,
    this.enableHtml = false,
    this.height = 100,
    this.maxLength,
    this.maxWords,
    this.minLength = 0,
    this.counterTextStyle,
    this.minWords = 0,
  });

  final double borderWidth;
  final Function(String value, TextEditingController controller)? onSaved;
  final Function(String value)? onChanged;
  final String? initialText;
  final bool isReadOnly;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? borderColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double borderRadius;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final bool showActionButton;
  final Widget? actionButtonIcon;
  final ValidationType validationType;
  final String Function()? originalPassword;
  final Color? backgroundColor;
  final bool showValidationMessage;
  final TextAlign textAlign;
  final int? maxLength;
  final bool enableHtml;
  final double height;
  final int? maxWords;
  final int minLength;
  final int minWords; 
  final TextStyle? counterTextStyle;

  final String? Function(String? value)? validation;

  @override
  State<CommonMultilineTextField> createState() => _CommonMultilineTextFieldState();
}

class _CommonMultilineTextFieldState extends State<CommonMultilineTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _obscureText;
  int wordCount = 0;
  int lengthCount = 0;

  // bool get _hasController => widget.controller != null;

  @override
  void initState() {
    super.initState();

    _obscureText =
        widget.validationType == ValidationType.validatePassword ||
        widget.validationType == ValidationType.validateConfirmPassword;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    // Set initial text only if the controller was provided
    if (widget.initialText != null) {
      _controller.text = widget.initialText ?? '';
    }

    _focusNode.addListener(() {
      setState(() {}); // rebuild to reflect focus changes
    });
  }

  // Add this helper method to clean the text
  String _cleanText(String text) {
    if (text.trim().isEmpty) return text;
    // Remove HTML tags
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Replace multiple spaces with a single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  @override
  void dispose() {
    try {
      _focusNode.dispose();
      // if (!_hasController) {
      _controller.dispose();
      // }
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color _iconColor() {
    return _focusNode.hasFocus ? CoreKit.instance.primaryColor : CoreKit.instance.outlineColor;
  }

  void _onSave(String? value) {
    if (widget.validationType == ValidationType.validateConfirmPassword)
      assert(
        widget.originalPassword == null,
        'Orginal Password can not be null for Confirm password filed',
      );
    if (widget.onSaved == null) return;
    widget.onSaved!(value?.trim() ?? '', _controller);
  }

  Widget _buildPasswordSuffixIcon() {
    return GestureDetector(
      onTap: _togglePasswordVisibility,
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: 10.w),
        child: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20.sp,
        ),
      ),
    );
  }

  TextStyle _getStyle({
    FontWeight? fontWeight,
    double? fontSize,
    Color? textColor,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: CoreKit.instance.fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: textColor,
      height: height,
      fontStyle: fontStyle,
    );
  }

  Color hintColor() {
    return CoreKit.instance.theme.inputDecorationTheme.hintStyle?.color ??
        CoreKit.instance.outlineColor;
  }

  OutlineInputBorder _buildBorder({required Color color, double? width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius.r),
      borderSide: BorderSide(color: color, width: width ?? widget.borderWidth.w),
    );
  }


  @override
  Widget build(BuildContext context) {
    // if (enableHtml) {
    //   return CustomQuillField(
    //     height: height,
    //     onSave: onSave,
    //     validator: validationType,
    //     initialText: initialText,
    //     readOnly: readOnly,
    //     hintText: hintText,
    //     borderRadius: borderRadius,
    //     backgroundColor: backgroundColor,
    //     borderColor: borderColor,
    //     borderWidth: borderWidth,
    //   );
    // }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.height),
      child: Column(
        children: [
          Expanded(
            child: TextFormField(
              textAlignVertical: TextAlignVertical.top,
              readOnly: widget.isReadOnly,
              maxLines: null,
              scrollPhysics: const BouncingScrollPhysics(),
              inputFormatters: [
                ...InputHelper.getInputFormatters(widget.validationType),
                if (widget.maxWords != null || widget.maxLength != null)
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Clean the text before processing
                    final cleanedText = _cleanText(newValue.text);

                    if (widget.maxLength != null) {
                      final int length = cleanedText.length;
                      if (length <= widget.maxLength!) {
                        setState(() {
                          lengthCount = length;
                        });
                        // Return the cleaned text
                        return TextEditingValue(
                          text: newValue.text,
                          selection: TextSelection.collapsed(offset: newValue.text.length),
                        );
                      }
                      return oldValue;
                    }

                    // Count words by splitting on whitespace and filtering out empty strings
                    final words = cleanedText.split(' ').where((word) => word.isNotEmpty).length;

                    // Allow the change if word count is within limit or if text is being deleted
                    if (words <= widget.maxWords! || newValue.text.length < oldValue.text.length) {
                      setState(() {
                        wordCount = words;
                      });
                      // Return the cleaned text
                      return TextEditingValue(
                        text: newValue.text,
                        selection: TextSelection.collapsed(offset: newValue.text.length),
                      );
                    }
                    return oldValue;
                  }),
              ],
              keyboardType: InputHelper.getKeyboardType(widget.validationType),
              textAlign: widget.textAlign,
              controller: _controller,
              focusNode: _focusNode,
              enableInteractiveSelection: !widget.isReadOnly,
              obscureText: _obscureText,
              onChanged: widget.onChanged,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: widget.textInputAction,
              onSaved: (v) {
                _onSave(v?.trim() ?? '');
              },
              maxLength: widget.maxLength,
              onFieldSubmitted: (v) {
                _onSave(v.trim());
              },
              onTap: widget.onTap,
              validator:
                  widget.validation ??
                  (value) {
                    final newValue = _cleanText(value?.trim() ?? '');
                    String? error = InputHelper.validate(
                      widget.validationType,
                      newValue,
                      originalPassword: widget.originalPassword?.call(),
                    );

                    if (newValue.isNotEmpty) {
                      if (widget.minLength > 0 && newValue.length < widget.minLength) {
                        error = 'Minimum ${widget.minLength} characters required';
                      }

                      final wordCount = newValue.split(' ').length;

                      if (widget.minWords > 0 && wordCount < widget.minWords) {
                        error = 'Minimum ${widget.minWords} words required';
                      }

                      if (widget.maxWords != null) {
                        if (wordCount - 1 > widget.maxWords!) {
                          error = 'Maximum ${widget.maxWords} words allowed';
                        }
                      }
                    }

                    // Return the error to show the error border, but return null for the message if showValidationMessage is false
                    return widget.showValidationMessage ? error : (error != null ? '' : null);
                  },

              style: _getStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),

              expands: true, // expands to fill parent height
              decoration: InputDecoration(
                filled: true,
                counterText: '',

                errorMaxLines: 1,
                errorStyle: widget.showValidationMessage
                    ? null
                    : _getStyle(fontSize: 0, fontWeight: FontWeight.w400),
                fillColor: widget.backgroundColor,
                hintStyle: _getStyle(
                  fontSize: 16.sp,
                  fontStyle:
                      CoreKit.instance.theme.inputDecorationTheme.hintStyle?.fontStyle ??
                      FontStyle.italic,
                  textColor: hintColor(),
                ),
                prefixIcon: Column(
                  children: [
                    widget.prefixText?.isNotEmpty == true
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 5,
                            ), // add some right padding to allow hint space
                            child: CommonText(text: widget.prefixText!, textColor: _iconColor()),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 10.w, right: widget.paddingHorizontal),
                            child: widget.prefixIcon,
                          ),
                  ],
                ),
                suffixIconConstraints: BoxConstraints(
                  maxWidth:
                      widget.suffixIcon == null &&
                          widget.validationType != ValidationType.validatePassword
                      ? widget.paddingHorizontal
                      : double.infinity,
                ),

                prefixIconConstraints: BoxConstraints(
                  maxWidth: widget.prefixIcon == null ? widget.paddingHorizontal : double.infinity,
                ),
                suffixIcon: widget.showActionButton
                    ? GestureDetector(
                        onTap: () {
                          _onSave(_controller.text.trim());
                        },
                        child: widget.actionButtonIcon ?? const Icon(Icons.search),
                      )
                    : widget.validationType == ValidationType.validatePassword
                    ? (_obscureText ? _buildPasswordSuffixIcon() : _buildPasswordSuffixIcon())
                    : Padding(
                        padding: EdgeInsets.only(right: 10, left: widget.paddingHorizontal),
                        child: widget.suffixIcon,
                      ),
                prefixIconColor: _iconColor(),
                suffixIconColor: _iconColor(),

                focusedBorder: _buildBorder(
                  color: widget.isReadOnly
                      ? (widget.borderColor ?? CoreKit.instance.outlineColor)
                      : CoreKit.instance.primaryColor,
                  width: widget.borderWidth.w,
                ),
                enabledBorder: _buildBorder(
                  color: widget.borderColor ?? CoreKit.instance.outlineColor,
                  width: widget.borderWidth.w,
                ),
                errorBorder: _buildBorder(color: Colors.red, width: widget.borderWidth.w),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.paddingHorizontal.w,
                  vertical: widget.paddingVertical.h,
                ),
                hintText: widget.hintText,
                labelText: widget.labelText,
              ),
            ),
          ),
         
          Row(
            children: [
              if ((widget.minLength != lengthCount && widget.minLength > 0) ||
                  (widget.minWords != wordCount && widget.minWords > 0))
                Text(
                  (widget.minLength > 0)
                      ? '$lengthCount/${widget.minLength}'
                      : '$wordCount/${widget.minWords}',
                  style: widget.counterTextStyle,
                ),

              const Spacer(), 
              if ((widget.maxLength ?? 0) > 0 || (widget.maxWords ?? 0) > 0)
                Text(
                  (widget.maxLength ?? 0) > 0
                      ? '$lengthCount/${widget.maxLength}'
                      : '$wordCount/${widget.maxWords}',
                  style: widget.counterTextStyle,
                ),
            ],
          ),
        ],
      ),
    );
  }


}
