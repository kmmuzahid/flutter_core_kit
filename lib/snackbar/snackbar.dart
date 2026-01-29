/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:41:00
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

// Keep track of the current snackbar route
PageRoute? _currentSnackBarRoute;

void showSnackBar(String text, {required SnackBarType type, Duration? customDuration}) {
  final context = CoreKit.instance.navigatorKey.currentContext;
  if (context == null || !context.mounted) return;

  final theme = CoreKit.instance.theme;
  final colorScheme = theme.colorScheme;
  final snackBarTheme = theme.snackBarTheme;

  // Map semantic colors from the ColorScheme
  final (accentColor, iconData) = _getSemanticColors(type, colorScheme);

  // Dynamic duration logic
  final int calculatedMs = 2000 + (text.length * 25);
  final Duration displayDuration = customDuration ?? Duration(milliseconds: calculatedMs);

  final navigator = Navigator.of(context, rootNavigator: true);

  // Remove the previous snackbar if it exists
  if (_currentSnackBarRoute != null) {
    navigator.removeRoute(_currentSnackBarRoute!);
    _currentSnackBarRoute = null;
  }

  // Create and push the new snackbar route
  final route = _SnackBarRoute(
    text: text,
    accentColor: accentColor,
    iconData: iconData,
    theme: theme,
    colorScheme: colorScheme,
    snackBarTheme: snackBarTheme,
    duration: displayDuration,
  );

  _currentSnackBarRoute = route;

  navigator.push(route).then((_) {
    // Clear the reference when the route is popped
    if (_currentSnackBarRoute == route) {
      _currentSnackBarRoute = null;
    }
  });
}

// Custom PageRoute for the snackbar
class _SnackBarRoute extends PageRoute {
  final String text;
  final Color accentColor;
  final IconData iconData;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final SnackBarThemeData snackBarTheme;
  final Duration duration;

  _SnackBarRoute({
    required this.text,
    required this.accentColor,
    required this.iconData,
    required this.theme,
    required this.colorScheme,
    required this.snackBarTheme,
    required this.duration,
  });

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => '';

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SnackBarPage(
      text: text,
      accentColor: accentColor,
      iconData: iconData,
      theme: theme,
      colorScheme: colorScheme,
      snackBarTheme: snackBarTheme,
      duration: duration,
      animation: animation,
    );
  }
}

class _SnackBarPage extends StatefulWidget {
  final String text;
  final Color accentColor;
  final IconData iconData;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final SnackBarThemeData snackBarTheme;
  final Duration duration;
  final Animation<double> animation;

  const _SnackBarPage({
    required this.text,
    required this.accentColor,
    required this.iconData,
    required this.theme,
    required this.colorScheme,
    required this.snackBarTheme,
    required this.duration,
    required this.animation,
  });

  @override
  State<_SnackBarPage> createState() => _SnackBarPageState();
}

class _SnackBarPageState extends State<_SnackBarPage> {
  @override
  void initState() {
    super.initState();
    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Prevent taps from going through
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: widget.animation, curve: Curves.easeOut)),
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.down,
                  onDismissed: (_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    margin: widget.snackBarTheme.insetPadding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.snackBarTheme.backgroundColor ?? widget.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding:
                          widget.snackBarTheme.insetPadding ??
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: widget.accentColor, width: 10),
                          right: BorderSide(color: widget.accentColor, width: 1),
                          top: BorderSide(color: widget.accentColor, width: 1),
                          bottom: BorderSide(color: widget.accentColor, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(widget.iconData, color: widget.accentColor, size: 24),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.text,
                              style:
                                  widget.theme.snackBarTheme.contentTextStyle ??
                                  TextStyle(
                                    color: widget.colorScheme.onSurface.withOpacity(0.85),
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
          ],
        ),
      ),
    );
  }
}

/// Extracts semantic colors strictly from the App's ColorScheme
(Color, IconData) _getSemanticColors(SnackBarType type, ColorScheme colorScheme) {
  switch (type) {
    case SnackBarType.success:
      return (const Color(0xFF10B981), Icons.check_circle_outline_rounded);

    case SnackBarType.error:
      return (colorScheme.error, Icons.error_outline_rounded);

    case SnackBarType.warning:
      return (colorScheme.tertiary, Icons.info_outline_rounded);

    case SnackBarType.info:
    default:
      return (colorScheme.primary, Icons.info_outline_rounded);
  }
}
