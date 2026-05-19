/// Author: Km Muzahid
/// Date: 2025-12-29
/// Email: km.muzahid@gmail.com
/// LastEditors: Km Muzahid
/// LastEditTime: 2026-01-26 11:45:00
library;

import 'package:core_kit/initializer.dart';
import 'package:core_kit/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

class GridConfig {
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool enableMassionary;
  final double aspectRatio;
  final int itemInRow;

  GridConfig({
    this.maxCrossAxisExtent = 200,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.enableMassionary = false,
    this.aspectRatio = 1,
    this.itemInRow = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridConfig &&
        other.maxCrossAxisExtent == maxCrossAxisExtent &&
        other.mainAxisSpacing == mainAxisSpacing &&
        other.crossAxisSpacing == crossAxisSpacing &&
        other.enableMassionary == enableMassionary &&
        other.aspectRatio == aspectRatio &&
        other.itemInRow == itemInRow;
  }

  @override
  int get hashCode {
    return maxCrossAxisExtent.hashCode ^
        mainAxisSpacing.hashCode ^
        crossAxisSpacing.hashCode ^
        enableMassionary.hashCode ^
        aspectRatio.hashCode ^
        itemInRow.hashCode;
  }
}

class SmartStaggeredLoader extends StatefulWidget {
  const SmartStaggeredLoader({
    required this.itemCount,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isLoadDone = false,
    this.padding,
    this.physics,
    super.key,
    this.topWidget,
    this.gridConfig,
    this.appbar,
    this.onColapsAppbar,
    this.limit = 20,
    this.scrollController,
    this.isSeperated = false,
    this.emptyWidget,
    this.onReorder,
    this.listLoaderConfig,
    this.backgroundColor = Colors.transparent,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final void Function()? onRefresh;
  final void Function(int page)? onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadDone;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Widget? topWidget;
  final Widget? appbar;
  final Widget? onColapsAppbar;
  final int limit;
  final ScrollController? scrollController;
  final Widget? emptyWidget;

  final bool isSeperated;
  final GridConfig? gridConfig;
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Per-instance loader config. Overrides the global ListLoaderConfig.
  final ListLoaderConfig? listLoaderConfig;

  /// Background color for the header delegate. Defaults to transparent.
  final Color backgroundColor;

  @override
  State<SmartStaggeredLoader> createState() => _SmartStaggeredLoaderState();
}

class _SmartStaggeredLoaderState extends State<SmartStaggeredLoader> {
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _stickyKey = GlobalKey();
  late final ScrollController _scrollController;
  late final GridConfig gridConfig;
  int? _dragStartIndex;

  double _appBarHeight = 0.0;
  double _stickyHeight = 0.0;
  final Debouncer _debounce = Debouncer(milliseconds: 500);
  bool _isContentScrollable = false;

  int getNextPage() {
    return ((widget.itemCount + widget.limit - 1) ~/ widget.limit) + 1;
  }

  @override
  void initState() {
    super.initState();
    gridConfig = widget.gridConfig ?? GridConfig();
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
    final isNearBottom = pos.pixels >= pos.maxScrollExtent - 200;

    if (isNearBottom &&
        widget.onLoadMore != null &&
        !widget.isLoading &&
        !widget.isLoadingMore &&
        !widget.isLoadDone &&
        widget.itemCount > 0) {
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
    // When onColapsAppbar is null, the appbar stays permanently pinned.
    final collapsedHeight =
        widget.onColapsAppbar != null && _stickyHeight > 0
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
      body: Stack(
        children: [
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
                  child: _buildScrollView(appBarSliver),
                )
              : _buildScrollView(appBarSliver),
        ],
      ),
    );
  }

  Widget _buildScrollView(Widget? appBarSliver) {
    return CustomScrollView(
      controller: _scrollController,
      physics:
          widget.physics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        ?appBarSliver,

        if (widget.topWidget != null)
          SliverToBoxAdapter(child: widget.topWidget),

        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: widget.itemCount == 0 && !widget.isLoading
              ? SliverToBoxAdapter(
                  child: _empty(),
                )
              : widget.onReorder != null
              ? ReorderableBuilder.builder(
                  itemCount: widget.itemCount,
                  onDragStarted: (index) {
                    _dragStartIndex = index;
                  },
                  onDragEnd: (index) {
                    if (_dragStartIndex != null) {
                      widget.onReorder!(_dragStartIndex!, index);
                      _dragStartIndex = null;
                    }
                  },
                  onReorderPositions: (positions) {
                     // Empty callback to satisfy ReorderableBuilder requirements
                  },
                  childBuilder: (itemBuilder) {
                    return SliverGrid(
                      gridDelegate: gridConfig.itemInRow > 0
                          ? SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridConfig.itemInRow,
                              childAspectRatio: gridConfig.aspectRatio,
                              mainAxisSpacing: gridConfig.mainAxisSpacing,
                              crossAxisSpacing: widget.isSeperated
                                  ? 0
                                  : gridConfig.crossAxisSpacing,
                            )
                          : SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: gridConfig.aspectRatio,
                              maxCrossAxisExtent: gridConfig.maxCrossAxisExtent,
                              mainAxisSpacing: gridConfig.mainAxisSpacing,
                              crossAxisSpacing: widget.isSeperated
                                  ? 0
                                  : gridConfig.crossAxisSpacing,
                            ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var child = widget.itemBuilder(context, index);
                          if (widget.isSeperated) {
                            child = LayoutBuilder(
                              builder: (context, constraints) {
                                return _seprated(index, child, constraints.maxWidth);
                              },
                            );
                          }
                          return itemBuilder(
                            KeyedSubtree(key: ValueKey('item_$index'), child: child),
                            index,
                          );
                        },
                        childCount: widget.itemCount,
                      ),
                    );
                  },
                )
              : SliverGrid(
                  gridDelegate: gridConfig.itemInRow > 0
                      ? SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridConfig.itemInRow,
                          childAspectRatio: gridConfig.aspectRatio,
                          mainAxisSpacing: gridConfig.mainAxisSpacing,
                          crossAxisSpacing: widget.isSeperated
                              ? 0
                              : gridConfig.crossAxisSpacing,
                        )
                      : SliverGridDelegateWithMaxCrossAxisExtent(
                          childAspectRatio: gridConfig.aspectRatio,
                          maxCrossAxisExtent: gridConfig.maxCrossAxisExtent,
                          mainAxisSpacing: gridConfig.mainAxisSpacing,
                          crossAxisSpacing: widget.isSeperated
                              ? 0
                              : gridConfig.crossAxisSpacing,
                        ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final child = widget.itemBuilder(context, index);
                    if (widget.isSeperated) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return _seprated(index, child, constraints.maxWidth);
                        },
                      );
                    }
                    return child;
                  }, childCount: widget.itemCount),
                ),
        ),

        SliverToBoxAdapter(child: _buildFooter()),
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
    if (widget.isLoading || widget.isLoadingMore) {
      return config.loaderWidget;
    }
    if (widget.isLoadDone && widget.itemCount > 0) {
      return config.noMoreDataWidget;
    }
    return const SizedBox.shrink();
  }

  Widget _empty() {
    return widget.emptyWidget ??
        Center(
          child: Image.asset(
            'assets/images/empty_icon.png', // path inside the library
            package: 'core_kit', // the library name as in pubspec.yaml
            width: 100,
            height: 100,
          ),
        );
  }

  Widget _seprated(int index, Widget child, double width) {
    final gridChildPosition = calculateGridChildInfo(
      index: index,
      totalChildren: widget.itemCount,
      maxCrossAxisExtent: gridConfig.maxCrossAxisExtent,
      width: width,
    );

    final spacing = gridConfig.crossAxisSpacing <= 0
        ? 0
        : gridConfig.crossAxisSpacing / 2;

    return Container(
      padding: EdgeInsets.only(
        left:
            (gridChildPosition.isLastInRow || gridChildPosition.isMiddleInRow
                    ? spacing
                    : 0)
                .toDouble(),
        right:
            (gridChildPosition.isFirstInRow || gridChildPosition.isMiddleInRow
                    ? spacing
                    : 0)
                .toDouble(),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: !gridChildPosition.isItInLastRow
              ? BorderSide(color: Colors.grey.withValues(alpha: .5), width: 1.4)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  GridChildInfo calculateGridChildInfo({
    required int index,
    required int totalChildren,
    required double maxCrossAxisExtent,
    required double width,
  }) {
    final childrenInRow = (width / maxCrossAxisExtent).ceil();
    final totalRows = (totalChildren / childrenInRow).ceil();
    final currentRow = (index / childrenInRow).floor();
    final positionInRow = index % childrenInRow;

    final isFirstInRow = positionInRow == 0;
    final isLastInRow =
        positionInRow == childrenInRow - 1 || index == totalChildren - 1;
    final isMiddleInRow = !isFirstInRow && !isLastInRow;
    final isItInLastRow = currentRow == totalRows - 1;

    return GridChildInfo(
      childrenInRow: childrenInRow,
      isFirstInRow: isFirstInRow,
      isMiddleInRow: isMiddleInRow,
      isLastInRow: isLastInRow,
      isItInLastRow: isItInLastRow,
    );
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
    final progress =
        shrinkRange > 0 ? (shrinkOffset / shrinkRange).clamp(0.0, 1.0) : 0.0;

    final collapsedOpacity = collapsedChild != null
        ? ((progress - 0.7) / 0.3).clamp(0.0, 1.0)
        : 0.0;

    return Material(
      color: backgroundColor,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: expandedChild,
            ),
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


class GridChildInfo {
  GridChildInfo({
    required this.childrenInRow,
    required this.isFirstInRow,
    required this.isMiddleInRow,
    required this.isLastInRow,
    required this.isItInLastRow,
  });
  final int childrenInRow;
  final bool isFirstInRow;
  final bool isMiddleInRow;
  final bool isLastInRow;
  final bool isItInLastRow;
}
