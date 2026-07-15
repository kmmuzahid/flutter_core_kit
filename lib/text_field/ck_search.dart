import 'dart:async';

import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CkSearch extends StatefulWidget {
  const CkSearch({
    super.key,
    this.onSearch,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixBuilder,
    this.prefixBuilder,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.borderWidth = 1.2,
    this.borderType = CkBorderType.outline,
    this.paddingHorizontal = 16,
    this.paddingVertical = 14,
    this.isReadOnly = false,
    this.textInputAction = TextInputAction.search,
    this.maxLength,
    this.fontSize,
    this.textStyle,
    this.hintStyle,
    this.textAlign = TextAlign.left,
    this.onTap,
    this.onFocusChanged,
    this.baseDelayMs = 300,
    this.incrementMs = 100,
    this.maxDelayMs = 800,
    this.showClearButton = true,
  });

  /// Debounced callback — fires only when the user pauses typing AND the text
  /// has actually changed since the last fired value.
  final Function(String value)? onSearch;

  final String? hintText;
  final TextEditingController? controller;

  /// Left-side icon. Defaults to [Icons.search] when null.
  final Widget? prefixIcon;

  /// Right-side icon. When provided, suppresses the built-in clear button.
  final Widget? suffixIcon;

  /// Dynamic suffix builder. When provided, suppresses the built-in clear button.
  final Widget? Function(TextEditingController controller, FocusNode focusNode)?
  suffixBuilder;

  /// Dynamic prefix builder. When provided, overrides [prefixIcon].
  final Widget? Function(TextEditingController controller, FocusNode focusNode)?
  prefixBuilder;

  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final double borderWidth;
  final CkBorderType borderType;
  final double paddingHorizontal;
  final double paddingVertical;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final int? maxLength;
  final double? fontSize;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final Function(FocusNode focusNode)? onFocusChanged;

  /// Base debounce delay in milliseconds. Default: 300ms.
  final int baseDelayMs;

  /// Extra milliseconds added to the delay per keystroke since the last fire.
  /// Grows the delay while the user is typing continuously (fast typers
  /// get a longer grace window). Default: 100ms.
  final int incrementMs;

  /// Upper cap for the adaptive delay. Default: 800ms.
  final int maxDelayMs;

  /// Shows a x clear button when the field is non-empty.
  /// Suppressed if [suffixIcon] or [suffixBuilder] is provided.
  final bool showClearButton;

  @override
  State<CkSearch> createState() => _CkSearchState();
}

class _CkSearchState extends State<CkSearch> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late ThemeData theme;

  /// The text most recently passed to [widget.onChanged].
  /// Used to skip redundant callbacks when the user navigates back to a
  /// previously searched text (e.g. types "hel" -> "hell" -> backspace -> "hel").
  String _lastSearchedText = '';

  /// Keystrokes accumulated since the last [widget.onChanged] call.
  /// Drives the adaptive delay calculation.
  int _pendingKeystrokes = 0;

  Timer? _debounceTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      widget.onFocusChanged?.call(_focusNode);
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Adaptive debounce
  // ---------------------------------------------------------------------------

  /// Called on every raw text change. Resets the timer with a growing delay:
  ///   effectiveDelay = clamp(baseDelayMs + pendingKeystrokes * incrementMs,
  ///                          baseDelayMs, maxDelayMs)
  void _onRawChanged(String _) {
    _pendingKeystrokes++;

    final effectiveDelay =
        (widget.baseDelayMs + _pendingKeystrokes * widget.incrementMs).clamp(
          widget.baseDelayMs,
          widget.maxDelayMs,
        );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: effectiveDelay), _fireIfNew);
  }

  /// Fires [widget.onChanged] only when the current text differs from
  /// [_lastSearchedText]. Always resets [_pendingKeystrokes].
  void _fireIfNew() {
    final current = _controller.text;
    _pendingKeystrokes = 0;
    if (current == _lastSearchedText) return; // results still valid — skip
    _lastSearchedText = current;
    widget.onSearch?.call(current);
  }

  /// Handles the clear button tap. Fires immediately (no debounce) because
  /// clearing is an explicit user action, not a mid-typing event.
  void _onClear() {
    _debounceTimer?.cancel();
    _pendingKeystrokes = 0;
    _controller.clear();
    _lastSearchedText = '';
    widget.onSearch?.call('');
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Helpers (mirrors CkTextField pattern)
  // ---------------------------------------------------------------------------

  Color _iconColor() {
    return _focusNode.hasFocus ? coreKitInstance.primaryColor : hintColor();
  }

  Color hintColor() {
    return coreKitInstance.theme.inputDecorationTheme.hintStyle?.color ??
        coreKitInstance.outlineColor;
  }

  TextStyle _getStyle({
    FontWeight? fontWeight,
    double? fontSize,
    Color? textColor,
    double? height,
    FontStyle? fontStyle,
  }) {
    return (widget.textStyle ?? const TextStyle()).copyWith(
      fontFamily: coreKitInstance.fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: textColor,
      height: height,
      fontStyle: fontStyle,
    );
  }

  Widget _buildPrefix() {
    final custom =
        widget.prefixBuilder?.call(_controller, _focusNode) ??
        widget.prefixIcon;
    return custom ??
        Icon(
          Icons.search,
          size: (widget.fontSize ?? 20).sp,
          color: _iconColor(),
        );
  }

  Widget? _buildSuffix() {
    // Caller-supplied suffix takes full priority — clear button is suppressed.
    final custom =
        widget.suffixBuilder?.call(_controller, _focusNode) ??
        widget.suffixIcon;
    if (custom != null) {
      return Padding(
        padding: EdgeInsets.only(right: 10, left: widget.paddingHorizontal),
        child: custom,
      );
    }

    // Built-in clear button.
    if (widget.showClearButton &&
        !widget.isReadOnly &&
        _controller.text.isNotEmpty) {
      return GestureDetector(
        onTap: _onClear,
        child: Padding(
          padding: EdgeInsets.only(right: 10, left: widget.paddingHorizontal),
          child: Icon(
            Icons.close,
            size: (widget.fontSize ?? 18).sp,
            color: _iconColor(),
          ),
        ),
      );
    }

    return null;
  }

  InputBorder _buildBorder({required Color color, double? width}) {
    final BorderRadius radius;
    if (widget.borderRadius != null) {
      radius = BorderRadius.circular(widget.borderRadius!.r);
    } else if (coreKitInstance.theme.inputDecorationTheme.border?.isOutline ==
        true) {
      radius =
          (coreKitInstance.theme.inputDecorationTheme.border!
                  as OutlineInputBorder)
              .borderRadius;
    } else {
      radius = BorderRadius.circular(12);
    }

    final side = BorderSide(color: color, width: width ?? widget.borderWidth.w);

    if (widget.borderType == CkBorderType.underline) {
      return UnderlineInputBorder(borderRadius: radius, borderSide: side);
    }
    return OutlineInputBorder(borderRadius: radius, borderSide: side);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasSuffix =
        widget.suffixIcon != null ||
        widget.suffixBuilder != null ||
        (widget.showClearButton &&
            !widget.isReadOnly &&
            _controller.text.isNotEmpty);

    return Material(
      type: MaterialType.transparency,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: widget.textAlign,
        readOnly: widget.isReadOnly,
        enableInteractiveSelection: !widget.isReadOnly,
        textInputAction: widget.textInputAction,
        keyboardType: TextInputType.text,
        maxLength: widget.maxLength,
        cursorColor: _focusNode.hasFocus
            ? (theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
                  coreKitInstance.primaryColor)
            : (theme.inputDecorationTheme.errorBorder?.borderSide.color ??
                  Colors.red),
        cursorErrorColor: _focusNode.hasFocus
            ? (theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
                  coreKitInstance.primaryColor)
            : (theme.inputDecorationTheme.errorBorder?.borderSide.color ??
                  Colors.red),
        onTapOutside: (event) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPosition = renderBox.globalToLocal(event.position);
            if (renderBox.paintBounds.contains(localPosition)) return;
          }
          _focusNode.unfocus();
        },
        onChanged: (value) {
          // Rebuild to show/hide the clear button, then run adaptive debounce.
          setState(() {});
          _onRawChanged(value);
        },
        onTap: widget.onTap,
        inputFormatters: [
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength!),
        ],
        style: _getStyle(
          fontWeight: FontWeight.w500,
          fontSize:
              widget.fontSize ??
              coreKitInstance.theme.inputDecorationTheme.hintStyle?.fontSize ??
              16.sp,
        ),
        decoration: InputDecoration(
          filled: true,
          counterText: '',
          fillColor: widget.backgroundColor,
          hintText: widget.hintText,
          hintStyle:
              widget.hintStyle ??
              _getStyle(
                fontSize:
                    widget.fontSize ??
                    coreKitInstance
                        .theme
                        .inputDecorationTheme
                        .hintStyle
                        ?.fontSize ??
                    16.sp,
                fontStyle:
                    coreKitInstance
                        .theme
                        .inputDecorationTheme
                        .hintStyle
                        ?.fontStyle ??
                    FontStyle.italic,
                textColor: hintColor(),
              ),

          // Prefix
          prefixIconConstraints: const BoxConstraints(
            maxWidth: double.infinity,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: 10.w,
              right: widget.paddingHorizontal,
            ),
            child: _buildPrefix(),
          ),
          prefixIconColor: _iconColor(),

          // Suffix
          suffixIconConstraints: BoxConstraints(
            maxWidth: hasSuffix ? double.infinity : widget.paddingHorizontal,
          ),
          suffixIcon: _buildSuffix(),
          suffixIconColor: _iconColor(),

          // Borders
          focusedBorder: _buildBorder(
            color: widget.isReadOnly
                ? (widget.borderColor ??
                      theme
                          .inputDecorationTheme
                          .disabledBorder
                          ?.borderSide
                          .color ??
                      coreKitInstance.outlineColor)
                : theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
                      coreKitInstance.primaryColor,
            width: widget.borderWidth.w,
          ),
          enabledBorder: _buildBorder(
            color:
                widget.borderColor ??
                theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                coreKitInstance.outlineColor,
            width: widget.borderWidth.w,
          ),
          errorBorder: _buildBorder(
            color:
                theme.inputDecorationTheme.errorBorder?.borderSide.color ??
                Colors.red,
            width: widget.borderWidth.w,
          ),
          disabledBorder: _buildBorder(
            color:
                widget.borderColor ??
                theme.inputDecorationTheme.disabledBorder?.borderSide.color ??
                coreKitInstance.outlineColor,
            width: widget.borderWidth.w,
          ),

          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.paddingHorizontal.w,
            vertical: widget.paddingVertical.h,
          ),
        ),
      ),
    );
  }
}
