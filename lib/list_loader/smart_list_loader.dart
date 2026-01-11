/// Author: Km Muzahid
/// Date: 2025-12-29
/// Email: km.muzahid@gmail.com
/// LastEditors: Km Muzahid
/// LastEditTime: 2025-12-29 11:40:00
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SmartListLoader extends StatefulWidget {
  const SmartListLoader({
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
  });

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

  @override
  State<SmartListLoader> createState() => _SmartListLoaderState();
}

class _SmartListLoaderState extends State<SmartListLoader> {
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _stickyKey = GlobalKey();
  late final ScrollController _scrollController;

  double _appBarHeight = 0.0;
  double _stickyHeight = 0.0;
  double _currentOffset = 0.0;

  int _page = 1;

  int getNextPage() {
    return ((widget.itemCount + widget.limit - 1) ~/ widget.limit) + 1;
  }

  @override
  void initState() {
    super.initState();
    _page = getNextPage();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateHeights());
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _currentOffset = _scrollController.offset;
    });

    final pos = _scrollController.position;
    final isAtEdge = widget.isReverse ? pos.pixels <= 100 : pos.pixels >= pos.maxScrollExtent - 200;

    if (isAtEdge && widget.onLoadMore != null && !widget.isLoading && !widget.isLoadDone) {
      widget.onLoadMore!(_page);
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

    // Define the slivers for the appbar/sticky header
    final appbarSlivers = [
      if (widget.appbar != null && _appBarHeight > 0 && _scrollController.position.pixels < 5)
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          titleSpacing: widget.padding?.horizontal ?? 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: _appBarHeight,
          automaticallyImplyLeading: false,
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
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Measurement layer (using your .h extension logic where applicable)
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
              reverse: widget.isReverse,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [ 
                if (widget.isReverse) _buildListSliver() else ...appbarSlivers,

                if (widget.isReverse)
                  ...appbarSlivers
                      .reversed // Reverse the appbar order internally
                else
                  _buildListSliver(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSliver() {
    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (!widget.isReverse && index == widget.itemCount || widget.isReverse && index == 0) {
            return _buildFooter();
          }
          final actualIndex = widget.isReverse ? index - 1 : index;
          if (actualIndex >= 0 && actualIndex < widget.itemCount) {
            return widget.itemBuilder(context, actualIndex);
          }
          return null;
        }, childCount: widget.itemCount + 1),
      ),
    );
  }

  Widget _buildFooter() {
    if (widget.isLoading) {
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
