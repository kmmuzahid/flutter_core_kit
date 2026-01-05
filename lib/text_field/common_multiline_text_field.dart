import 'package:core_kit/core_kit.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:core_kit/text_field/input_helper.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:core_kit/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

                    // Check word count if maxWords is set
                    if (widget.maxWords != null && newValue.isNotEmpty) {
                      final wordCount = newValue.split(' ').length;
                      if (wordCount - 1 > widget.maxWords!) {
                        error = 'Maximum ${widget.maxWords} words allowed';
                      }
                    }

                    // Return the error to show the error border, but return null for the message if showValidationMessage is false
                    return widget.showValidationMessage ? error : (error != null ? '' : null);
                  },

              style: (getTheme.textTheme.bodyLarge ?? CoreKit.instance.defaultTextStyle)?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),

              expands: true, // expands to fill parent height
              decoration: InputDecoration(
                filled: true,
                counterText: '',

                errorMaxLines: 1,
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                fillColor: widget.backgroundColor,
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: CoreKit.instance.outlineColor,
                  fontStyle: FontStyle.italic,
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

                focusedBorder: OutlineInputBorder(
                  borderSide: getTheme.inputDecorationTheme.focusedBorder!.borderSide.copyWith(
                    color: widget.isReadOnly
                        ? (widget.borderColor ?? getTheme.dividerColor)
                        : getTheme.primaryColor,
                    width: widget.borderWidth.w,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                ),

                errorBorder: OutlineInputBorder(
                  borderSide: getTheme.inputDecorationTheme.errorBorder!.borderSide.copyWith(
                    color: Colors.red,
                    width: widget.borderWidth.w,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: getTheme.inputDecorationTheme.enabledBorder!.borderSide.copyWith(
                    color: widget.borderColor ?? getTheme.dividerColor,
                    width: widget.borderWidth.w,
                  ),

                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.paddingHorizontal.w,
                  vertical: widget.paddingVertical.h,
                ),
                hintText: widget.hintText,
                labelText: widget.labelText,
              ),
            ),
          ),
          if ((widget.maxLength ?? 0) > 0 || (widget.maxWords ?? 0) > 0)
            Text(
              (widget.maxLength ?? 0) > 0
                  ? '$lengthCount/${widget.maxLength}'
                  : '$wordCount/${widget.maxWords}',
            ).end,
        ],
      ),
    );
  }
}
