/// Author: Km Muzahid
/// Date: 2025-12-29
/// Email: km.muzahid@gmail.com
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; 

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
    this.maxCrossAxisExtent = 200,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.physics,
    super.key,
    this.topWidget,
    this.enableMassionary = false,
    this.aspectRatio = 1,
    this.appbar,
    this.onColapsAppbar,
    this.isSeperated = false,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final void Function()? onRefresh;
  final void Function()? onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadDone;
  final EdgeInsetsGeometry? padding;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final ScrollPhysics? physics;
  final Widget? topWidget;
  final bool enableMassionary;
  final double aspectRatio;
  final Widget? appbar;
  final Widget? onColapsAppbar;
  final bool isSeperated;

  @override
  State<SmartStaggeredLoader> createState() => _SmartStaggeredLoaderState();
}

class _SmartStaggeredLoaderState extends State<SmartStaggeredLoader> {
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _stickyKey = GlobalKey();
  late final ScrollController _scrollController;

  double _appBarHeight = 0.0;
  double _stickyHeight = 0.0;
  double _currentOffset = 0.0;
  double _position = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateHeights());
  }

  void _scrollListener() {
    _position = _scrollController.position.pixels;
    if (!_scrollController.hasClients) return;

    setState(() {
      _currentOffset = _scrollController.offset;
    });

    final pos = _scrollController.position;
    final isNearBottom = pos.pixels >= pos.maxScrollExtent - 200;

    if (isNearBottom &&
        widget.onLoadMore != null &&
        !widget.isLoading &&
        !widget.isLoadingMore &&
        !widget.isLoadDone &&
        widget.itemCount > 0) {
      widget.onLoadMore!();
    }
  }

  void _updateHeights() {
    final appBarBox = _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final stickyBox = _stickyKey.currentContext?.findRenderObject() as RenderBox?;

    setState(() {
      _appBarHeight = appBarBox?.size.height ?? 0.0;
      _stickyHeight = stickyBox?.size.height ?? 0.0;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAppBarCollapsed = _currentOffset >= _appBarHeight;

    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(key: _appBarKey, child: widget.appbar ?? const SizedBox()),
                Container(key: _stickyKey, child: widget.onColapsAppbar ?? const SizedBox()),
              ],
            ),
          ),

          RefreshIndicator(
            onRefresh: () async => widget.onRefresh?.call(),
            child: CustomScrollView(
              controller: _scrollController,
              physics:
                  widget.physics ??
                  const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                if (widget.appbar != null && _position < 10)
                  SliverAppBar(
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

                if (widget.onColapsAppbar != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      height: _stickyHeight,
                      visible: isAppBarCollapsed,
                      child: widget.onColapsAppbar!,
                    ),
                  ),

                if (widget.topWidget != null) SliverToBoxAdapter(child: widget.topWidget),

                SliverPadding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  sliver: widget.itemCount == 0 && !widget.isLoading
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('No data found')),
                        )
                      : SliverGrid(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            childAspectRatio: widget.aspectRatio,
                            maxCrossAxisExtent: widget.maxCrossAxisExtent,
                            mainAxisSpacing: widget.mainAxisSpacing,
                            crossAxisSpacing: widget.isSeperated ? 0 : widget.crossAxisSpacing,
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
            ),
          ),
        ],
      ),
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

  Widget _seprated(int index, Widget child, double width) {
    final gridChildPosition = calculateGridChildInfo(
      index: index,
      totalChildren: widget.itemCount,
      maxCrossAxisExtent: widget.maxCrossAxisExtent,
      width: width,
    );

    final spacing = widget.crossAxisSpacing <= 0 ? 0 : widget.crossAxisSpacing / 2;

    return Container(
      padding: EdgeInsets.only(
        left: (gridChildPosition.isLastInRow || gridChildPosition.isMiddleInRow ? spacing : 0)
            .toDouble(),
        right: (gridChildPosition.isFirstInRow || gridChildPosition.isMiddleInRow ? spacing : 0)
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
    final isLastInRow = positionInRow == childrenInRow - 1 || index == totalChildren - 1;
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

  _StickyHeaderDelegate({required this.height, required this.child, required this.visible});
  final double height;
  final Widget child;
  final bool visible;

  @override
  double get minExtent => visible ? height : 0.0;
  @override
  double get maxExtent => visible ? height : 0.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
