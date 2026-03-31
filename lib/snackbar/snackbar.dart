/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:41:00
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

OverlayEntry? _currentSnackBarEntry;

void showSnackBar(
  String text, {
  required SnackBarType type,
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

// Always reads live theme from CoreKit — supports dynamic dark/light switching
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
  final SnackBarType type;
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

    // Exact same animation as original
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
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

          return Material(
            color: Colors.transparent,
            child: Align(
              heightFactor: 1,
              // Replaces Stack + Positioned — avoids ParentData conflict on page push
              // while achieving identical bottom positioning
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.down,
                  onDismissed: (_) => _dismiss(),
                  child: Container(
                    padding: EdgeInsets.zero,
                    margin:
                        snackBarTheme.insetPadding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          snackBarTheme.backgroundColor ?? colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding:
                          snackBarTheme.insetPadding ??
                          const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 10,
                          ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: accentColor, width: 10),
                          right: BorderSide(color: accentColor, width: 1),
                          top: BorderSide(color: accentColor, width: 1),
                          bottom: BorderSide(color: accentColor, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(iconData, color: accentColor, size: 24),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.text,
                              style:
                                  snackBarTheme.contentTextStyle ??
                                  TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.85,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ],
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

/// Extracts semantic colors strictly from the App's ColorScheme
(Color, IconData) _getSemanticColors(
  SnackBarType type,
  ColorScheme colorScheme,
) {
  switch (type) {
    case SnackBarType.success:
      return (const Color(0xFF10B981), Icons.check_circle_outline_rounded);
    case SnackBarType.error:
      return (colorScheme.error, Icons.error_outline_rounded);
    case SnackBarType.warning:
      return (colorScheme.tertiary, Icons.info_outline_rounded);
    case SnackBarType.info:
      return (colorScheme.primary, Icons.info_outline_rounded);
  }
}
