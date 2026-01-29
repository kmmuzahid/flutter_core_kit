import 'package:core_kit/initializer.dart';
import 'package:core_kit/text_field/input_formatters/input_helper.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../text/common_text.dart';
import 'validation_type.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    required this.validationType,
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.maxLength,
    this.prefixText,
    this.paddingHorizontal = 16,
    this.paddingVertical = 14,
    this.borderRadius,
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
    this.maxWords, 
  });

  final double borderWidth;
  final int? maxWords;
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
  final double? borderRadius;
  final int? maxLength;
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

  final String? Function(String? value)? validation;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _obscureText;
  int wordCount = 0;
  int lengthCount = 0;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = Theme.of(CoreKit.instance.navigatorKey.currentContext!);
    _obscureText =
        widget.validationType == ValidationType.validatePassword ||
        widget.validationType == ValidationType.validateConfirmPassword;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    if (widget.initialText != null) {
      _controller.text = widget.initialText ?? '';
    }
    

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _onSave(_controller.text);
      }
      setState(() {});
    });

  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color _iconColor() {
    return _focusNode.hasFocus ? CoreKit.instance.primaryColor : hintColor();
  }

  void _onSave(String? value) {
    if (widget.validationType == ValidationType.validateConfirmPassword)
      assert(
        widget.originalPassword != null,
        'Original Password cannot be null for Confirm password field',
      );
    if (widget.onSaved != null) widget.onSaved!(value?.trim() ?? '', _controller);
  }

  String _cleanText(String text) {
    if (text.trim().isEmpty) return text;
    String cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  /// Helper: Returns TextStyle from theme with optional overrides
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

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ((widget.maxLength ?? 0) > 0 || (widget.maxWords ?? 0) > 0)
          ? Column(
              children: [
                _buildTextField(),
                if ((widget.maxLength ?? 0) > 0 || (widget.maxWords ?? 0) > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      (widget.maxLength ?? 0) > 0
                          ? '$lengthCount/${widget.maxLength}'
                          : '$wordCount/${widget.maxWords}',
                      style: _getStyle(fontSize: 12.sp, textColor: CoreKit.instance.outlineColor),
                    ),
                  ),
              ],
            )
          : _buildTextField(),
    );
  }

  Color hintColor() {
    return CoreKit.instance.theme.inputDecorationTheme.hintStyle?.color ??
        CoreKit.instance.outlineColor;
  }

  TextFormField _buildTextField() {
    return TextFormField(
      textAlign: widget.textAlign,
      controller: _controller,
      focusNode: _focusNode,
      onTapOutside: (event) => _focusNode.unfocus(),
      enableInteractiveSelection: !widget.isReadOnly,
      obscureText: _obscureText,
      onTapUpOutside: (event) {
        _onSave(_controller.text);
      },
      
      readOnly: widget.isReadOnly,
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: InputHelper.getKeyboardType(widget.validationType),
      textInputAction: widget.textInputAction,
      onSaved: (v) => _onSave(v?.trim() ?? ''),
      maxLength: widget.maxLength,
      inputFormatters: [
        ...InputHelper.getInputFormatters(widget.validationType),
        if (widget.maxWords != null || widget.maxLength != null)
          TextInputFormatter.withFunction((oldValue, newValue) {
            final cleanedText = _cleanText(newValue.text);

            if (widget.maxLength != null) {
              final int length = cleanedText.length;
              if (length <= widget.maxLength!) {
                setState(() => lengthCount = length);
                return newValue.copyWith(
                  text: newValue.text,
                  selection: TextSelection.collapsed(offset: newValue.text.length),
                );
              }
              return oldValue;
            }

            if (widget.maxWords != null) {
              final words = cleanedText.split(' ').where((w) => w.isNotEmpty).length;
              if (words <= widget.maxWords! || newValue.text.length < oldValue.text.length) {
                setState(() => wordCount = words);
                return newValue.copyWith(
                  text: newValue.text,
                  selection: TextSelection.collapsed(offset: newValue.text.length),
                );
              }
            }

            return oldValue;
          }),
      ],
      onFieldSubmitted: (v) => _onSave(v.trim()),
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
            if (widget.maxWords != null && newValue.isNotEmpty && wordCount > widget.maxWords!) {
              error = 'Maximum ${widget.maxWords} words allowed';
            }
            return widget.showValidationMessage ? error : (error != null ? '' : null);
          },
      style: _getStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
      decoration: InputDecoration(
      
        filled: true,
        counterText: '',
        errorMaxLines: widget.showValidationMessage ? 2 : 1,
        errorStyle: widget.showValidationMessage
            ? null
            : _getStyle(fontSize: 0, fontWeight: FontWeight.w400),
        fillColor: widget.backgroundColor,
        hintStyle: _getStyle(
          fontSize: 16.sp,
          fontStyle:
              CoreKit.instance.theme.inputDecorationTheme.hintStyle?.fontStyle ?? FontStyle.italic,
          textColor: hintColor(),
        ),
        prefixIcon: widget.prefixText?.isNotEmpty == true
            ? Padding(
                padding: const EdgeInsets.only(left: 10, right: 5),
                child: CommonText(text: widget.prefixText!, textColor: _iconColor()),
              )
            : Padding(
                padding: EdgeInsets.only(left: 10.w, right: widget.paddingHorizontal),
                child: widget.prefixIcon,
              ),
        suffixIconConstraints: BoxConstraints(
          maxWidth:
              widget.suffixIcon == null && widget.validationType != ValidationType.validatePassword
              ? widget.paddingHorizontal
              : double.infinity,
        ),
        prefixIconConstraints: BoxConstraints(
          maxWidth: widget.prefixIcon == null ? widget.paddingHorizontal : double.infinity,
        ),
        suffixIcon: widget.showActionButton
            ? GestureDetector(
                onTap: () => _onSave(_controller.text.trim()),
                child: widget.actionButtonIcon ?? const Icon(Icons.search),
              )
            : widget.validationType == ValidationType.validatePassword
            ? (_buildPasswordSuffixIcon())
            : Padding(
                padding: EdgeInsets.only(right: 10, left: widget.paddingHorizontal),
                child: widget.suffixIcon,
              ),
        prefixIconColor: _iconColor(),
        suffixIconColor: _iconColor(),
        focusedBorder: _buildBorder(
          color: widget.isReadOnly
              ? (widget.borderColor ??
                    theme.inputDecorationTheme.disabledBorder?.borderSide.color ??
                    CoreKit.instance.outlineColor)
              : theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
                    CoreKit.instance.primaryColor,
          width: widget.borderWidth.w,
        ),
        enabledBorder: _buildBorder(
          color:
              widget.borderColor ??
              theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
              CoreKit.instance.outlineColor,
          width: widget.borderWidth.w,
        ),
        errorBorder: _buildBorder(
          color: theme.inputDecorationTheme.errorBorder?.borderSide.color ?? Colors.red,
          width: widget.borderWidth.w,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.paddingHorizontal.w,
          vertical: widget.paddingVertical.h,
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
      ),
    );
  }

  OutlineInputBorder _buildBorder({required Color color, double? width}) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius == null
          ? CoreKit.instance.theme.inputDecorationTheme.border?.isOutline == true
                ? (CoreKit.instance.theme.inputDecorationTheme.border as OutlineInputBorder)
                      .borderRadius
                : BorderRadius.circular(12)
          : BorderRadius.circular(widget.borderRadius?.r ?? 0),
      borderSide: BorderSide(color: color, width: width ?? widget.borderWidth.w),
    );
  }

  Widget _buildPasswordSuffixIcon() {
    return GestureDetector(
      onTap: _togglePasswordVisibility,
      child: Padding(
        padding: CoreKit.instance.passWordObscureIcon.padding,
        child: _obscureText
            ? CoreKit.instance.passWordObscureIcon.hide
            : CoreKit.instance.passWordObscureIcon.show,
      ),
    );
  }
}
