/// Author: Km Muzahid
/// Date: 2025-12-29
/// Email: km.muzahid@gmail.com
/// LastEditors: Km Muzahid
/// LastEditTime: 2026-01-26 11:45:00
library;

import 'package:core_kit/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  @override
  State<SmartStaggeredLoader> createState() => _SmartStaggeredLoaderState();
}

class _SmartStaggeredLoaderState extends State<SmartStaggeredLoader> {
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _stickyKey = GlobalKey();
  late final ScrollController _scrollController;
  late final GridConfig gridConfig;

  double _appBarHeight = 0.0;
  double _stickyHeight = 0.0;
  double _currentOffset = 0.0;
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

    if (mounted) {
      setState(() {
        _currentOffset = _scrollController.offset;
      });
    }

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
    final isAppBarCollapsed =
        _scrollController.hasClients &&
        _currentOffset >= _appBarHeight &&
        _isContentScrollable;

    // Show main appbar when at top or content is not scrollable
    final showMainAppBar =
        widget.appbar != null &&
        _appBarHeight > 0 &&
        (_scrollController.hasClients
            ? (_scrollController.offset < _appBarHeight ||
                  !_isContentScrollable)
            : true);

    // Show collapsed appbar when content is scrollable and scrolled past threshold
    final showCollapsedAppBar =
        widget.onColapsAppbar != null &&
        ((isAppBarCollapsed && _isContentScrollable) ||
            (!showMainAppBar && _isContentScrollable));

    return Scaffold(
      body: Stack(
        children: [
          Offstage(
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

          widget.onRefresh != null
              ? RefreshIndicator(
                  onRefresh: () async => widget.onRefresh?.call(),
                  // Disable refresh when content doesn't fill the screen
                  notificationPredicate: (notification) {
                    if (!_isContentScrollable) {
                      return false;
                    }
                    return notification.depth == 0;
                  },
                  child: _buildScrollView(showMainAppBar, showCollapsedAppBar),
                )
              : _buildScrollView(showMainAppBar, showCollapsedAppBar),
        ],
      ),
    );
  }

  Widget _buildScrollView(bool showMainAppBar, bool showCollapsedAppBar) {
    return CustomScrollView(
      controller: _scrollController,
      physics:
          widget.physics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        if (showMainAppBar)
          SliverAppBar(
            primary: false,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: _appBarHeight,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            titleSpacing: 0,
            title: widget.appbar,
          ),

        if (showCollapsedAppBar)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: _stickyHeight,
              visible: true,
              child: widget.onColapsAppbar!,
            ),
          ),

        if (widget.topWidget != null)
          SliverToBoxAdapter(child: widget.topWidget),

        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: widget.itemCount == 0 && !widget.isLoading
              ? SliverToBoxAdapter(
                  // hasScrollBody: false,
                  child: _empty(),
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
    if (widget.isLoading || widget.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.isLoadDone && widget.itemCount > 0) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No more data', style: TextStyle(color: Colors.grey)),
        ),
      );
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

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({
    required this.height,
    required this.child,
    required this.visible,
  });
  final double height;
  final Widget child;
  final bool visible;

  @override
  double get minExtent => visible ? height : 0.0;
  @override
  double get maxExtent => visible ? height : 0.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return visible ? child : const SizedBox.shrink();
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.visible != visible || oldDelegate.child != child;
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
