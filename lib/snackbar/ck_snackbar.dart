import 'package:core_kit/initializer.dart';
import 'package:core_kit/snackbar/ck_snackbar_config.dart';
import 'package:flutter/material.dart';

enum CkSnackBarType { success, error, warning, info }

OverlayEntry? _currentSnackBarEntry;

// ignore: non_constant_identifier_names
void CkSnackBar(
  String text, {
  required CkSnackBarType type,
  Duration? customDuration,
}) {
  final overlayState = coreKitInstance.navigatorKey.currentState?.overlay;
  if (overlayState == null) return;

  final calculatedMs = 2000 + (text.length * 25);
  final displayDuration =
      customDuration ?? Duration(milliseconds: calculatedMs);

  _currentSnackBarEntry?.remove();
  _currentSnackBarEntry = null;

  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _SnackBarOverlay(
      text: text,
      type: type,
      duration: displayDuration,
      onDismiss: () {
        entry.remove();
        if (_currentSnackBarEntry == entry) {
          _currentSnackBarEntry = null;
        }
      },
    ),
  );

  _currentSnackBarEntry = entry;
  overlayState.insert(entry);
}

class _ThemeWrapper extends StatelessWidget {
  final Widget child;

  const _ThemeWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(data: coreKitInstance.theme, child: child);
  }
}

class _SnackBarOverlay extends StatefulWidget {
  final String text;
  final CkSnackBarType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SnackBarOverlay({
    required this.text,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SnackBarOverlay> createState() => _SnackBarOverlayState();
}

class _SnackBarOverlayState extends State<_SnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final position = coreKitInstance.snackBarConfig.position ?? CkSnackBarPosition.bottom;
    _slideAnimation = Tween<Offset>(
      begin: position == CkSnackBarPosition.top ? const Offset(0, -1) : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;

    _controller.reverse().then((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeWrapper(
      child: Builder(
        builder: (themeContext) {
          final theme = Theme.of(themeContext);
          final colorScheme = theme.colorScheme;
          final snackBarTheme = theme.snackBarTheme;
          final (accentColor, iconData) = _getSemanticColors(
            widget.type,
            colorScheme,
          );

          final config = coreKitInstance.snackBarConfig;
          final position = config.position ?? CkSnackBarPosition.bottom;
          final borderRadius = config.borderRadius ?? 12;
          final margin = config.margin ?? snackBarTheme.insetPadding ?? const EdgeInsets.all(16);
          final padding = config.padding ?? snackBarTheme.insetPadding ?? const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          );
          final backgroundColor = config.backgroundColor ?? snackBarTheme.backgroundColor ?? colorScheme.surface;
          final boxShadow = config.boxShadow ?? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ];
          final borderWidthLeft = config.borderWidthLeft ?? 10;
          final borderWidthOthers = config.borderWidthOthers ?? 1;
          final iconSize = config.iconSize ?? 24;
          final textStyle = config.textStyle ?? snackBarTheme.contentTextStyle ?? TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          );

          return IgnorePointer(
            ignoring: true,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                top: position == CkSnackBarPosition.top,
                bottom: position == CkSnackBarPosition.bottom,
                child: Align(
                  heightFactor: 1,
                  alignment: position == CkSnackBarPosition.top ? Alignment.topCenter : Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: IgnorePointer(
                      ignoring: false,
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: position == CkSnackBarPosition.top ? DismissDirection.up : DismissDirection.down,
                        onDismissed: (_) => _dismiss(),
                        child: Container(
                          padding: EdgeInsets.zero,
                          margin: margin,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: backgroundColor,
                            boxShadow: boxShadow,
                          ),
                          child: Container(
                            padding: padding,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              border: Border(
                                left: BorderSide(color: accentColor, width: borderWidthLeft),
                                right: BorderSide(color: accentColor, width: borderWidthOthers),
                                top: BorderSide(color: accentColor, width: borderWidthOthers),
                                bottom: BorderSide(color: accentColor, width: borderWidthOthers),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(iconData, color: accentColor, size: iconSize),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.text,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

(Color, IconData) _getSemanticColors(
  CkSnackBarType type,
  ColorScheme colorScheme,
) {
  final config = coreKitInstance.snackBarConfig;
  switch (type) {
    case CkSnackBarType.success:
      return (
        config.successColor ?? const Color(0xFF10B981),
        config.successIcon ?? Icons.check_circle_outline_rounded,
      );
    case CkSnackBarType.error:
      return (
        config.errorColor ?? colorScheme.error,
        config.errorIcon ?? Icons.error_outline_rounded,
      );
    case CkSnackBarType.warning:
      return (
        config.warningColor ?? colorScheme.tertiary,
        config.warningIcon ?? Icons.info_outline_rounded,
      );
    case CkSnackBarType.info:
      return (
        config.infoColor ?? colorScheme.primary,
        config.infoIcon ?? Icons.info_outline_rounded,
      );
  }
}
