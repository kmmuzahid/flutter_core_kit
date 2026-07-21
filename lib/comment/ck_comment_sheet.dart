import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

/// Returns the direct replies/children of [item]. Called recursively, so
/// replies can themselves have replies — depth is not limited to 2 levels.
typedef CkRepliesExtractor<T> = List<T> Function(T item);

/// Returns a stable, unique identifier for [item]. Used as the key for the
/// internal expand/collapse state, so it must not depend on object identity
/// (the same logical item may be represented by a new instance after a
/// refetch).
typedef CkIdExtractor<T> = String Function(T item);

/// Builds everything for [item] except the avatar, reaction row and reply
/// action (those are separate builders below) — typically the name/header
/// row, the comment text and any attached media.
typedef CkCommentContentBuilder<T> =
    Widget Function(BuildContext context, T item, int depth);

/// Builds the avatar for [item]. Fully self-contained, including its own
/// tap handling (e.g. navigating to a profile screen) if any.
typedef CkCommentAvatarBuilder<T> = Widget Function(T item, int depth);

/// Builds the reaction control(s) for [item] (e.g. a like/reaction stack).
typedef CkCommentReactionBuilder<T> = Widget Function(T item);

/// Builds the "reply" affordance for [item]. [expandReplies] is supplied by
/// the sheet — call it from your widget's tap handler (in addition to any
/// app-specific logic, like focusing a composer) to reveal [item]'s replies.
typedef CkCommentReplyActionBuilder<T> =
    Widget Function(T item, int depth, VoidCallback expandReplies);

/// Returns the avatar size to use at a given nesting [depth] (0 = top level).
typedef CkAvatarSizeForDepth = double Function(int depth);

/// Builds the composer's toolbar (e.g. a type dropdown, media pickers, an AI
/// writer button) — everything except the send button, which the sheet
/// places according to [CkSendButtonPosition]. [controller] is the sheet's
/// own composer text controller, so app-specific widgets (like an AI writer)
/// can read/write the same text.
typedef CkComposerFooterBuilder =
    Widget Function(BuildContext context, TextEditingController controller);

/// Where the send button is rendered relative to the composer text box.
enum CkSendButtonPosition {
  /// Inside the text box's footer, to the right of [CkComposerFooterBuilder].
  footer,

  /// Outside the text box, to its right, bottom-aligned when focused.
  outsideTextField,
}

/// A generic, recursively-nested comment/reply list with built-in
/// expand/collapse-replies state, connector-line drawing, and pagination —
/// built on top of [CkListView] for the outer scroll/refresh/load-more
/// mechanics.
///
/// [T] is your comment model; this widget has no knowledge of its shape.
class CkCommentSheet<T> extends StatefulWidget {
  const CkCommentSheet({
    super.key,
    required this.items,
    required this.repliesOf,
    required this.idOf,
    required this.itemBuilder,
    required this.avatarBuilder,
    required this.replyActionBuilder,
    required this.reactionBuilder,
    this.previewHeaderBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.onLoadMoreReplies,
    this.isLoading = false,
    this.isLoadDone = false,
    this.replyPageSize = 2,
    this.avatarSizeForDepth = _defaultAvatarSizeForDepth,
    this.exclusiveReplyExpansion = true,
    this.scrollController,
    this.padding,
    this.dividerBuilder,
    this.gap = 8,
    this.itemBottomSpacing = 16,
    this.accentColor,
    this.dividerColor,
    this.toggleTextStyle,
    this.replyTarget,
    this.onSend,
    this.composerFooterBuilder,
    this.sendButtonBuilder,
    this.sendButtonPosition = CkSendButtonPosition.footer,
    this.showComposer = true,
    this.composerHintText = 'Write a comment...',
    this.composerMinHeight = 100,
    this.composerFocusedHeight = 160,
    this.composerMaximizedHeightFraction = 0.5,
    this.composerBackgroundColor,
    this.composerOnChanged,
    this.composerContainerBuilder,
    this.composerMaxLength,
    this.composerMaxWords,
    this.composerMinLength = 0,
    this.composerMinWords = 0,
    this.composerCounterTextStyle,
    this.composerLimitHintBuilder,
  });

  /// The top-level items (e.g. comments on a post).
  final List<T> items;

  final CkRepliesExtractor<T> repliesOf;
  final CkIdExtractor<T> idOf;
  final CkCommentContentBuilder<T> itemBuilder;
  final CkCommentAvatarBuilder<T> avatarBuilder;
  final CkCommentReplyActionBuilder<T> replyActionBuilder;
  final CkCommentReactionBuilder<T> reactionBuilder;

  /// Rendered above the list (forwarded to [CkListView.topWidget]) — e.g. a
  /// "replying to ..." / "comment on post ..." context header.
  final WidgetBuilder? previewHeaderBuilder;

  final void Function()? onRefresh;

  /// Pagination for the top-level [items] list.
  final void Function(int page)? onLoadMore;

  /// Pagination for [parent]'s replies, called whenever more of an
  /// already-known parent's replies are requested. The sheet always reveals
  /// any already-available items from [repliesOf] first; use this to fetch
  /// more from the network when needed.
  final void Function(T parent, int page)? onLoadMoreReplies;

  final bool isLoading;
  final bool isLoadDone;

  /// How many replies become visible per "View more replies" tap.
  final int replyPageSize;

  final CkAvatarSizeForDepth avatarSizeForDepth;

  /// When true (default), expanding the replies of a top-level item
  /// collapses the currently-expanded top-level item, if any. Nested
  /// expansions within the same top-level subtree are unaffected.
  final bool exclusiveReplyExpansion;

  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  /// Overrides the default divider rendered after every item/reply.
  final WidgetBuilder? dividerBuilder;

  /// Horizontal gap between the avatar column and its content.
  final double gap;

  /// Vertical space after each top-level item (and its expanded replies)
  /// before the next one.
  final double itemBottomSpacing;

  /// Color used for the "View replies" / "Hide replies" icon and text.
  /// Defaults to `Theme.of(context).colorScheme.primary`.
  final Color? accentColor;

  /// Color used for connector lines and the default divider.
  /// Defaults to `Theme.of(context).dividerColor`.
  final Color? dividerColor;

  final TextStyle? toggleTextStyle;

  /// The item the composer is currently replying to, if any. Pass `null` for
  /// a new top-level comment. This is a controlled prop — update it from
  /// your own reactive state when the user taps a [replyActionBuilder].
  final T? replyTarget;

  /// Called when the user taps send. [replyTo] mirrors [replyTarget] at the
  /// moment of sending: `null` means "post a new top-level comment",
  /// non-null means "reply to this item". The sheet clears its own text
  /// field after calling this; you're responsible for clearing any of your
  /// own state (e.g. attached media) and persisting the comment.
  final void Function(String text, T? replyTo)? onSend;

  /// Builds the composer's toolbar. If null, no toolbar is shown.
  final CkComposerFooterBuilder? composerFooterBuilder;

  /// Builds the send button, given the tap handler to wire up. Defaults to
  /// a plain [IconButton] with [Icons.send].
  final Widget Function(VoidCallback onTap)? sendButtonBuilder;

  final CkSendButtonPosition sendButtonPosition;

  /// Whether the composer is visible. The composer only renders at all when
  /// [onSend] is provided. Controlled externally — e.g. drive this from your
  /// own show/hide state if you want a collapsible composer.
  final bool showComposer;

  final String composerHintText;

  /// Height of the composer text box when not focused.
  final double composerMinHeight;

  /// Height of the composer text box when focused but not maximized.
  final double composerFocusedHeight;

  /// Fraction of the screen height used when the composer is maximized.
  final double composerMaximizedHeightFraction;

  final Color? composerBackgroundColor;

  /// Called on every composer text change.
  final void Function(String value)? composerOnChanged;

  /// Wraps the composer's text field with its container chrome (background,
  /// border radius, padding, shadow, etc). Defaults to a plain white rounded
  /// card if not provided.
  final Widget Function(BuildContext context, Widget textField, bool isFocused)?
  composerContainerBuilder;

  /// Maximum characters allowed in the composer text field.
  final int? composerMaxLength;

  /// Maximum words allowed in the composer text field.
  final int? composerMaxWords;

  /// Minimum characters required in the composer text field.
  final int composerMinLength;

  /// Minimum words required in the composer text field.
  final int composerMinWords;

  /// Text style for the word/character count indicators.
  final TextStyle? composerCounterTextStyle;

  /// Custom builder for limit hints.
  final CkMultilineHintLimitBuilder? composerLimitHintBuilder;

  static double _defaultAvatarSizeForDepth(int depth) => depth == 0 ? 32 : 24;

  @override
  State<CkCommentSheet<T>> createState() => _CkCommentSheetState<T>();
}

class _CkCommentSheetState<T> extends State<CkCommentSheet<T>> {
  final Map<String, int> _visibleReplyCount = {};
  String? _expandedTopLevelId;

  final TextEditingController _composerController = TextEditingController();
  FocusNode? _composerFocusNode;
  bool _isComposerFocused = false;
  bool _isComposerMaximized = false;

  @override
  void didUpdateWidget(covariant CkCommentSheet<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final justShown = widget.showComposer && !oldWidget.showComposer;
    final replyTargetChanged =
        widget.replyTarget != null &&
        widget.replyTarget != oldWidget.replyTarget;
    if (justShown || replyTargetChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _composerFocusNode?.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _composerController.text.trim();
    widget.onSend?.call(text, widget.replyTarget);
    _composerController.clear();
    _composerFocusNode?.unfocus();
    setState(() => _isComposerMaximized = false);
  }

  double _avatarSize(int depth) => widget.avatarSizeForDepth(depth);

  double _connectorAreaWidth(int depth) {
    double width = 0;
    for (var i = 0; i < depth; i++) {
      width += _avatarSize(i) + widget.gap;
    }
    return width;
  }

  double _avatarCenterX(int depth) =>
      _connectorAreaWidth(depth) + _avatarSize(depth) / 2;

  void _expandReplies(T item, int depth) {
    final id = widget.idOf(item);
    setState(() {
      if (depth == 0 &&
          widget.exclusiveReplyExpansion &&
          _expandedTopLevelId != null &&
          _expandedTopLevelId != id) {
        _visibleReplyCount.clear();
      }
      if (depth == 0) {
        _expandedTopLevelId = id;
      }
      if ((_visibleReplyCount[id] ?? 0) == 0) {
        _visibleReplyCount[id] = widget.replyPageSize;
      }
    });
  }

  void _showMoreReplies(T item, int depth, int visibleClamped) {
    final id = widget.idOf(item);
    setState(() {
      if (visibleClamped == 0 &&
          depth == 0 &&
          widget.exclusiveReplyExpansion &&
          _expandedTopLevelId != null &&
          _expandedTopLevelId != id) {
        _visibleReplyCount.clear();
      }
      if (depth == 0) {
        _expandedTopLevelId = id;
      }
      _visibleReplyCount[id] = visibleClamped + widget.replyPageSize;
    });
    widget.onLoadMoreReplies?.call(
      item,
      (visibleClamped ~/ widget.replyPageSize) + 2,
    );
  }

  void _hideReplies(T item) {
    final id = widget.idOf(item);
    setState(() {
      _visibleReplyCount[id] = 0;
      for (final child in widget.repliesOf(item)) {
        _clearDescendants(child);
      }
      if (_expandedTopLevelId == id) {
        _expandedTopLevelId = null;
      }
    });
  }

  void _clearDescendants(T item) {
    _visibleReplyCount.remove(widget.idOf(item));
    for (final child in widget.repliesOf(item)) {
      _clearDescendants(child);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget list = CkListView(
      itemCount: widget.items.length,
      padding: widget.padding,
      scrollController: widget.scrollController,
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      isLoading: widget.isLoading,
      isLoadDone: widget.isLoadDone,
      topWidget: widget.previewHeaderBuilder?.call(context),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return Padding(
          padding: EdgeInsets.only(bottom: widget.itemBottomSpacing),
          child: _buildSubtree(
            context,
            item,
            0,
            isLastChild: true,
            ancestorLineXs: const [],
          ),
        );
      },
    );

    if (widget.onSend == null) return list;

    return Column(
      children: [
        Expanded(child: list),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: widget.showComposer
              ? GestureDetector(
                  // Consume taps so an ancestor's "tap outside to dismiss"
                  // handler doesn't fire when interacting with the composer.
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: _buildComposer(context),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildComposer(BuildContext context) {
    final hasCounter =
        widget.composerMaxLength != null ||
        widget.composerMaxWords != null ||
        widget.composerMinLength > 0 ||
        widget.composerMinWords > 0;

    final baseHeight = !_isComposerFocused
        ? widget.composerMinHeight
        : (_isComposerMaximized
              ? MediaQuery.of(context).size.height *
                    widget.composerMaximizedHeightFraction
              : widget.composerFocusedHeight);

    final containerHeight =
        baseHeight + (hasCounter ? (_isComposerFocused ? 34 : 25.0) : 0.0);

    final sendButton =
        widget.sendButtonBuilder?.call(_handleSend) ??
        IconButton(onPressed: _handleSend, icon: const Icon(Icons.send));

    final toolbar =
        widget.composerFooterBuilder?.call(context, _composerController) ??
        const SizedBox.shrink();

    final Widget textField = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: containerHeight,
      child: CkMultilineTextField(
        controller: _composerController,
        validationType: CkValidationType.notRequired,
        hintText: widget.composerHintText,
        backgroundColor: widget.composerBackgroundColor ?? Colors.transparent,
        borderColor: Colors.transparent,
        enableMaximize: false,
        height: baseHeight,
        maxLength: widget.composerMaxLength,
        maxWords: widget.composerMaxWords,
        minLength: widget.composerMinLength,
        minWords: widget.composerMinWords,
        counterTextStyle: widget.composerCounterTextStyle,
        multilineLimitHintBuilder: widget.composerLimitHintBuilder,
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: toolbar),
            if (widget.sendButtonPosition == CkSendButtonPosition.footer) ...[
              SizedBox(width: widget.gap),
              sendButton,
            ],
          ],
        ),
        suffixIcon: _isComposerFocused
            ? SizedBox(
                width: 32,
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _isComposerMaximized = !_isComposerMaximized,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Icon(
                        _isComposerMaximized
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        onChanged: widget.composerOnChanged,
        onFocusChanged: (focusNode) {
          _composerFocusNode = focusNode;
          setState(() {
            _isComposerFocused = focusNode.hasFocus;
            if (!focusNode.hasFocus) _isComposerMaximized = false;
          });
        },
      ),
    );

    final box =
        widget.composerContainerBuilder?.call(
          context,
          textField,
          _isComposerFocused,
        ) ??
        Container(
          padding: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: textField,
        );

    if (widget.sendButtonPosition == CkSendButtonPosition.outsideTextField) {
      return _wrapWithReplyAvatar(
        Row(
          crossAxisAlignment: _isComposerFocused
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
          children: [
            Expanded(child: box),
            SizedBox(width: widget.gap),
            sendButton,
          ],
        ),
      );
    }
    return _wrapWithReplyAvatar(box);
  }

  /// Wraps [composerRow] with the reply-target's avatar, when replying.
  Widget _wrapWithReplyAvatar(Widget composerRow) {
    return composerRow;
    // return Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     widget.avatarBuilder(widget.replyTarget as T, 0),
    //     SizedBox(width: widget.gap * 1.5),
    //     Expanded(child: composerRow),
    //   ],
    // );
  }

  Widget _buildSubtree(
    BuildContext context,
    T item,
    int depth, {
    required bool isLastChild,
    required List<double> ancestorLineXs,
  }) {
    final replies = widget.repliesOf(item);
    final hasReplies = replies.isNotEmpty;
    final id = widget.idOf(item);
    final visible = _visibleReplyCount[id] ?? 0;

    final node = _buildNode(
      context,
      item,
      depth,
      isLastChild: isLastChild,
      hasSpineBelow: hasReplies,
      ancestorLineXs: ancestorLineXs,
    );

    if (!hasReplies) return node;

    final parentCenterX = _avatarCenterX(depth);
    final childAncestorLineXs = <double>[...ancestorLineXs, parentCenterX];
    final visibleClamped = visible.clamp(0, replies.length);
    final remaining = replies.length - visibleClamped;

    final repliesWidgets = <Widget>[];
    for (var i = 0; i < visibleClamped; i++) {
      repliesWidgets.add(
        _buildSubtree(
          context,
          replies[i],
          depth + 1,
          // The toggle row below is always the last child at this level.
          isLastChild: false,
          ancestorLineXs: childAncestorLineXs,
        ),
      );
    }

    final Widget repliesSection = AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: repliesWidgets,
        ),
      ),
    );

    final toggleRow = _buildToggleRow(
      context,
      depth: depth + 1,
      ancestorLineXs: childAncestorLineXs,
      child: remaining > 0
          ? _toggleControl(
              context,
              icon: Icons.keyboard_arrow_down,
              label:
                  'View ${remaining.clamp(0, widget.replyPageSize) == remaining ? remaining : widget.replyPageSize} repl${remaining == 1 ? 'y' : 'ies'}',
              onTap: () => _showMoreReplies(item, depth, visibleClamped),
            )
          : _toggleControl(
              context,
              icon: Icons.keyboard_arrow_up,
              label: 'Hide replies',
              onTap: () => _hideReplies(item),
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [node, repliesSection, toggleRow],
    );
  }

  Widget _toggleControl(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style:
                widget.toggleTextStyle ??
                TextStyle(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    T item,
    int depth, {
    required bool isLastChild,
    required bool hasSpineBelow,
    required List<double> ancestorLineXs,
  }) {
    final avatarSize = _avatarSize(depth);
    final avatar = widget.avatarBuilder(item, depth);
    final lineColor = widget.dividerColor ?? Theme.of(context).dividerColor;

    if (depth == 0) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: avatarSize,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  if (hasSpineBelow)
                    CustomPaint(
                      painter: _CkVerticalLinePainter(
                        x: avatarSize / 2,
                        color: lineColor,
                      ),
                    ),
                  Positioned(top: 0, left: 0, right: 0, child: avatar),
                ],
              ),
            ),
            SizedBox(width: widget.gap),
            Expanded(child: _buildContentColumn(context, item, depth)),
          ],
        ),
      );
    }

    const double topPad = 8;
    final avatarCenterY = topPad + avatarSize / 2;
    final parentLineX = ancestorLineXs.last;
    final straightAncestors = ancestorLineXs.sublist(
      0,
      ancestorLineXs.length - 1,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _connectorAreaWidth(depth),
            child: CustomPaint(
              painter: _CkReplyConnectorPainter(
                parentLineX: parentLineX,
                isLastChild: isLastChild,
                avatarCenterY: avatarCenterY,
                straightAncestorLineXs: straightAncestors,
                color: lineColor,
              ),
            ),
          ),
          SizedBox(
            width: avatarSize,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                if (hasSpineBelow)
                  CustomPaint(
                    painter: _CkVerticalLinePainter(
                      x: avatarSize / 2,
                      startY: topPad + avatarSize,
                      color: lineColor,
                    ),
                  ),
                Positioned(top: topPad, left: 0, right: 0, child: avatar),
              ],
            ),
          ),
          SizedBox(width: widget.gap),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: topPad),
              child: _buildContentColumn(context, item, depth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required int depth,
    required List<double> ancestorLineXs,
    required Widget child,
  }) {
    const lineCenterY = 12.0;
    final parentLineX = ancestorLineXs.last;
    final straightAncestors = ancestorLineXs.sublist(
      0,
      ancestorLineXs.length - 1,
    );
    final lineColor = widget.dividerColor ?? Theme.of(context).dividerColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _connectorAreaWidth(depth),
            child: CustomPaint(
              painter: _CkReplyConnectorPainter(
                parentLineX: parentLineX,
                isLastChild: true,
                avatarCenterY: lineCenterY,
                straightAncestorLineXs: straightAncestors,
                color: lineColor,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentColumn(BuildContext context, T item, int depth) {
    final lineColor = widget.dividerColor ?? Theme.of(context).dividerColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.itemBuilder(context, item, depth),
        SizedBox(height: widget.gap),
        Row(
          children: [
            widget.reactionBuilder(item),
            SizedBox(width: widget.gap * 2),
            widget.replyActionBuilder(
              item,
              depth,
              () => _expandReplies(item, depth),
            ),
          ],
        ),
        SizedBox(height: widget.gap),
        widget.dividerBuilder?.call(context) ?? Divider(color: lineColor),
      ],
    );
  }
}

class _CkVerticalLinePainter extends CustomPainter {
  final double x;
  final double startY;
  final Color color;

  _CkVerticalLinePainter({
    required this.x,
    this.startY = 0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, startY), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CkReplyConnectorPainter extends CustomPainter {
  final double parentLineX;
  final bool isLastChild;
  final double avatarCenterY;
  final List<double> straightAncestorLineXs;
  final Color color;

  _CkReplyConnectorPainter({
    required this.parentLineX,
    required this.isLastChild,
    required this.avatarCenterY,
    required this.straightAncestorLineXs,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const radius = 14.0;

    for (final x in straightAncestorLineXs) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    if (isLastChild) {
      canvas.drawLine(
        Offset(parentLineX, 0),
        Offset(parentLineX, avatarCenterY - radius),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(parentLineX, 0),
        Offset(parentLineX, size.height),
        paint,
      );
    }

    final path = Path()
      ..moveTo(parentLineX, avatarCenterY - radius)
      ..quadraticBezierTo(
        parentLineX,
        avatarCenterY,
        parentLineX + radius,
        avatarCenterY,
      )
      ..lineTo(size.width, avatarCenterY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
