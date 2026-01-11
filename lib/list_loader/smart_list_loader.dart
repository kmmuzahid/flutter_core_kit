/// Author: Km Muzahid
/// Date: 2025-12-29
/// Email: km.muzahid@gmail.com
/// LastEditors: Km Muzahid
/// LastEditTime: 2025-12-29 11:40:00
library;

import 'package:core_kit/utils/core_screen_utils.dart';
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

/*
 * @Author: Km Muzahid 
 * @Date: 2026-01-11 16:30:00
 * @Email: km.muzahid@gmail.com
 */
@override
Widget build(BuildContext context) {
    // Fix 1: Adjust collapse logic for reverse
    // In reverse, _currentOffset increases as you scroll towards the "top" (older messages)
    final isAppBarCollapsed = widget.isReverse
        ? _scrollController.hasClients && _scrollController.offset > 20.h
        : _currentOffset >= _appBarHeight;

    // Fix 2: Adjust AppBar visibility trigger
    // In reverse, we show the main appbar only when at the absolute bottom (pixels < 5)
    final bool showMainAppBar =
        widget.appbar != null &&
        _appBarHeight > 0 &&
        (_scrollController.hasClients ? _scrollController.position.pixels < 5 : true);

    final appBarWidgets = [
      if (showMainAppBar)
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
            // If reverse, we want this visible as soon as we scroll away from the bottom
            visible: isAppBarCollapsed,
            child: widget.onColapsAppbar!,
          ),
        ),
    ];

    final listSliver = SliverPadding(
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

    return Scaffold(
      body: Stack(
        children: [
          // Measurement layer
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
                // If reverse, the list comes first (it starts from bottom)
                // If not reverse, the appbar comes first
                if (widget.isReverse) listSliver else ...appBarWidgets,
              
                // If reverse, the appbar is placed at the "end" (visual top)
                if (widget.isReverse) ...appBarWidgets.reversed else listSliver,
              ],
            ),
          ),
        ],
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
