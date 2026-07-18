import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CkListView extends StatefulWidget {
  const CkListView({
    required this.itemCount,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadDone = false,
    this.isReverse = false,
    this.padding,
    this.appbar,
    this.onColapsAppbar,
    this.limit = 10,
    super.key,
    this.initalLoader,
    this.scrollController,
    this.emptyWidget,
    this.topWidget,
    this.onReorder,
    this.seperator,
    this.listLoaderConfig,
    this.backgroundColor = Colors.transparent,
    this.physics,
    this.shimmerItem,
  });

  final Widget? seperator;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final void Function()? onRefresh;
  final void Function(int page)? onLoadMore;
  final bool isLoading;
  final bool isLoadDone;
  final bool isReverse;
  final EdgeInsetsGeometry? padding;
  final Widget? appbar;
  final Widget? onColapsAppbar;
  final int limit;
  final Widget? initalLoader;
  final ScrollController? scrollController;
  final Widget? emptyWidget;
  final Widget? topWidget;
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Per-instance loader config. Overrides the global CkListLoaderConfig.
  final CkListLoaderConfig? listLoaderConfig;

  /// Background color for the header delegate. Defaults to transparent.
  final Color backgroundColor;

  /// Custom scroll physics. Defaults to AlwaysScrollableScrollPhysics.
  final ScrollPhysics? physics;

  /// Widget used as the shimmer placeholder for each item.
  /// Shown as [limit] repeated skeleton tiles when [isLoading] is true and [itemCount] is 0.
  final Widget? shimmerItem;

  @override
  State<CkListView> createState() => _CkListViewState();
}

class _CkListViewState extends State<CkListView> {
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _stickyKey = GlobalKey();
  late final ScrollController _scrollController;
  final CkDebouncer _debounce = CkDebouncer(milliseconds: 500);

  double _appBarHeight = 0.0;
  double _stickyHeight = 0.0;
  bool _isContentScrollable = false;

  int getNextPage() {
    return ((widget.itemCount + widget.limit - 1) ~/ widget.limit) + 1;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateHeights();
      _checkScrollability();
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    _checkScrollability();

    final pos = _scrollController.position;
    final isAtEdge = widget.isReverse
        ? pos.pixels <= 100
        : pos.pixels >= pos.maxScrollExtent - 200;

    if (isAtEdge &&
        widget.onLoadMore != null &&
        !widget.isLoading &&
        !widget.isLoadDone) {
      _debounce.run(() {
        if (mounted) {
          widget.onLoadMore!(getNextPage());
        }
      });
    }
  }

  void _checkScrollability() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final isScrollable = pos.maxScrollExtent > 0;
    if (_isContentScrollable != isScrollable && mounted) {
      setState(() {
        _isContentScrollable = isScrollable;
      });
    }
  }

  void _updateHeights() {
    final appBarBox =
        _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final stickyBox =
        _stickyKey.currentContext?.findRenderObject() as RenderBox?;

    if (mounted) {
      setState(() {
        _appBarHeight = appBarBox?.size.height ?? 0.0;
        _stickyHeight = stickyBox?.size.height ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sliverContent = widget.isLoading && widget.itemCount == 0 && widget.shimmerItem != null
        ? _buildShimmerSliver()
        : widget.itemCount == 0 && !widget.isLoading
        ? SliverToBoxAdapter(child: _empty())
        : widget.onReorder != null
        ? SliverReorderableList(
            onReorder: widget.onReorder!,
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              final actualIndex = widget.isReverse
                  ? (widget.itemCount - 1 - index)
                  : index;

              var item = widget.itemBuilder(context, actualIndex);

              if (widget.seperator != null) {
                final showSeparator = widget.isReverse
                    ? index > 0
                    : index < widget.itemCount - 1;
                if (showSeparator) {
                  item = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [item, widget.seperator!],
                  );
                }
              }

              return ReorderableDelayedDragStartListener(
                key: ValueKey('item_$actualIndex'),
                index: index,
                child: item,
              );
            },
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (widget.seperator != null) {
                  final itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    return widget.seperator!;
                  }
                  final actualIndex = widget.isReverse
                      ? (widget.itemCount - 1 - itemIndex)
                      : itemIndex;
                  return widget.itemBuilder(context, actualIndex);
                }
                final actualIndex = widget.isReverse
                    ? (widget.itemCount - 1 - index)
                    : index;
                return widget.itemBuilder(context, actualIndex);
              },
              childCount: widget.seperator != null
                  ? (widget.itemCount > 0 ? widget.itemCount * 2 - 1 : 0)
                  : widget.itemCount,
            ),
          );

    final listSlivers = [
      if (widget.initalLoader != null &&
          widget.isLoading &&
          widget.itemCount == 0 &&
          widget.shimmerItem == null)
        SliverToBoxAdapter(child: widget.initalLoader!)
      else ...[
        if (!widget.isReverse && widget.topWidget != null)
          SliverToBoxAdapter(child: widget.topWidget!),

        if (widget.isReverse) SliverToBoxAdapter(child: _buildFooter()),

        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: sliverContent,
        ),

        if (!widget.isReverse) SliverToBoxAdapter(child: _buildFooter()),

        if (widget.isReverse && widget.topWidget != null)
          SliverToBoxAdapter(child: widget.topWidget!),
      ],
    ];

    // The combined appbar sliver. Using pinned: true (never floating, never
    // snapping) so there are zero involuntary scroll animations. It shrinks
    // from _appBarHeight (full appbar) to _stickyHeight (collapsed bar) as
    // the user scrolls. Works correctly for any item count — no mode switching.
    // When onColapsAppbar is null, the appbar should never hide — it stays
    // permanently pinned. We achieve this by setting collapsedHeight = _appBarHeight
    // so minExtent == maxExtent and the header never shrinks.
    final collapsedHeight = widget.onColapsAppbar != null && _stickyHeight > 0
        ? _stickyHeight
        : _appBarHeight;

    // When _appBarHeight hasn't been measured yet (frame 1), show the appbar
    // as a plain SliverToBoxAdapter so content is correctly positioned from
    // the very first paint — no flash of missing appbar.
    // Once height is known (frame 2+) we switch to the pinned collapsing header.
    final Widget? appBarSliver;
    if (widget.appbar == null) {
      appBarSliver = null;
    } else if (_appBarHeight == 0) {
      // Frame 1: no height known yet, render as a normal scrollable item.
      appBarSliver = SliverToBoxAdapter(child: widget.appbar!);
    } else {
      appBarSliver = SliverPersistentHeader(
        pinned: true,
        delegate: _AppBarCollapseDelegate(
          expandedHeight: _appBarHeight,
          collapsedHeight: collapsedHeight,
          expandedChild: widget.appbar!,
          collapsedChild: widget.onColapsAppbar,
          backgroundColor: widget.backgroundColor,
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          // Measurement layer — scoped to a dummy Form so any FormFields
          // inside appbar/collapseAppbar do not double-register to the
          // parent page's Form.
          Form(
            child: Offstage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: _appBarKey,
                    child: widget.appbar ?? const SizedBox(),
                  ),
                  Container(
                    key: _stickyKey,
                    child: widget.onColapsAppbar ?? const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          widget.onRefresh != null
              ? RefreshIndicator(
                  onRefresh: () async => widget.onRefresh?.call(),
                  notificationPredicate: (notification) {
                    if (!_isContentScrollable) return false;
                    return notification.depth == 0;
                  },
                  child: _buildScrollView(appBarSliver, listSlivers),
                )
              : _buildScrollView(appBarSliver, listSlivers),
        ],
      ),
    );
  }

  Widget _buildShimmerSliver() {
    final count = widget.seperator != null
        ? widget.limit * 2 - 1
        : widget.limit;
    return SliverSkeletonizer(
      enabled: true,
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (widget.seperator != null && i.isOdd) return widget.seperator!;
            return widget.shimmerItem!;
          },
          childCount: count,
        ),
      ),
    );
  }

  Widget _empty() {
    return widget.emptyWidget ??
        Center(
          child: Image.asset(
            'assets/images/empty_icon.png',
            package: 'core_kit',
            width: 100,
            height: 100,
          ),
        );
  }

  Widget _buildScrollView(Widget? appBarSliver, List<Widget> listSlivers) {
    return CustomScrollView(
      controller: _scrollController,
      reverse: widget.isReverse,
      physics:
          widget.physics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        if (widget.isReverse) ...listSlivers,
        if (!widget.isReverse && appBarSliver != null) appBarSliver,
        if (!widget.isReverse) ...listSlivers,
        if (widget.isReverse && appBarSliver != null) appBarSliver,
      ],
    );
  }

  Widget _buildFooter() {
    final globalConfig = coreKitInstance.listLoaderConfig;
    final config = widget.listLoaderConfig != null
        ? globalConfig.copyWith(
            loaderWidget: widget.listLoaderConfig!.loaderWidget,
            noMoreDataWidget: widget.listLoaderConfig!.noMoreDataWidget,
          )
        : globalConfig;
    if (widget.isLoading) {
      return config.loaderWidget;
    }
    if (widget.isLoadDone && widget.itemCount > 0) {
      return config.noMoreDataWidget;
    }
    return const SizedBox.shrink();
  }
}

/// Handles the smooth collapse from the full appbar to the compact sticky bar.
/// Uses [pinned: true] — no floating, no snap — so scrolling is always
/// 1-to-1 with user input. No auto-animation, no flicker.
class _AppBarCollapseDelegate extends SliverPersistentHeaderDelegate {
  _AppBarCollapseDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.expandedChild,
    required this.collapsedChild,
    required this.backgroundColor,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget expandedChild;
  final Widget? collapsedChild;
  final Color backgroundColor;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkRange = expandedHeight - collapsedHeight;
    // progress: 0.0 = fully expanded, 1.0 = fully collapsed
    final progress = shrinkRange > 0
        ? (shrinkOffset / shrinkRange).clamp(0.0, 1.0)
        : 0.0;

    // The appbar content is always rendered and gets clipped by the header
    // bounds as the header shrinks — this is natural and gap-free.
    // The collapsed bar fades in starting at 70% progress so it appears
    // only when the appbar is almost gone (no overlap, no invisible gap).
    final collapsedOpacity = collapsedChild != null
        ? ((progress - 0.7) / 0.3).clamp(0.0, 1.0)
        : 0.0;

    return Material(
      color: backgroundColor,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Appbar anchored to top — clips naturally as header shrinks
            Positioned(top: 0, left: 0, right: 0, child: expandedChild),

            // Collapsed bar anchored to bottom — slides in as header shrinks,
            // then fades in for a clean handoff
            if (collapsedChild != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: collapsedHeight,
                child: IgnorePointer(
                  ignoring: collapsedOpacity == 0,
                  child: Opacity(
                    opacity: collapsedOpacity,
                    child: collapsedChild,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AppBarCollapseDelegate old) {
    return old.expandedHeight != expandedHeight ||
        old.collapsedHeight != collapsedHeight ||
        old.expandedChild != expandedChild ||
        old.collapsedChild != collapsedChild ||
        old.backgroundColor != backgroundColor;
  }
}

