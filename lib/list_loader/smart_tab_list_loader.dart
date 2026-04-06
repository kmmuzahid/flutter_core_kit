/// Author: Km Muzahid
/// Date: 2026-03-29
/// Email: km.muzahid@gmail.com
library;

import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

class SmartTabContext<T> {
  const SmartTabContext({
    required this.tab,
    required this.index,
    required this.itemCount,
    required this.isLoading,
    required this.isLoadDone,
  });

  /// The tab identifier (enum, String, etc.)
  final T tab;

  /// The tab's position in the list.
  final int index;

  /// Current item count for this tab.
  final int itemCount;

  /// Whether this tab is currently loading.
  final bool isLoading;

  /// Whether this tab has finished loading all pages.
  final bool isLoadDone;

  @override
  String toString() =>
      'SmartTabContext(tab: $tab, index: $index, itemCount: $itemCount, '
      'isLoading: $isLoading, isLoadDone: $isLoadDone)';
}

class SmartTabConfig<T> {
  const SmartTabConfig({
    required this.tab,
    required this.itemCount,
    this.isLoading = false,
    this.isLoadDone = false,
    this.gridConfig,
    this.initalLoader,
    this.emptyWidget,
  });

  final T tab;

  final int itemCount;
  final bool isLoading;
  final bool isLoadDone;
  final Widget? initalLoader;
  final Widget? emptyWidget;
  final GridConfig? gridConfig;
}

// ignore: must_be_immutable
class SmartTabListLoader<T> extends StatefulWidget {
  SmartTabListLoader({
    required this.tabs,
    required this.itemBuilder,
    this.onTabControllerReady,
    this.onPageChange,
    this.onLoadMore,
    this.onRefresh,
    this.isReverse = false,
    this.padding,
    this.appbar,
    this.onColapsAppbar,
    this.limit = 10,
    required this.value,
    this.gridConfig,
    this.emptyWidget,
    super.key,
  }) : assert(tabs.isNotEmpty, 'tabs must not be empty');

  final T value;

  final Widget? emptyWidget;

  final GridConfig? gridConfig;

  /// One config entry per tab — data/state only.
  List<SmartTabConfig<T>> tabs;

  /// Builds each list item. Receives full tab context + the item index.
  final Widget Function(SmartTabContext<T> ctx, int itemIndex) itemBuilder;

  /// Called once the internal [TabController] is ready.
  /// Use this to drive tab switching from your own appbar UI.
  /// e.g. controller.animateTo(index)
  final void Function(TabController controller)? onTabControllerReady;

  /// Called when the active tab changes.
  final void Function(SmartTabContext<T> ctx)? onPageChange;

  /// Called when a tab needs to load the next page.
  final void Function(SmartTabContext<T> ctx, int page)? onLoadMore;

  /// Called when a tab is pulled to refresh.
  final void Function(SmartTabContext<T> ctx)? onRefresh;

  final bool isReverse;

  /// Shared across all tabs.
  final EdgeInsetsGeometry? padding;

  /// Main appbar — shown at top, scrolls away. Collapses into [onColapsAppbar].
  final Widget? appbar;

  /// Collapsed/sticky appbar — always pinned once [appbar] scrolls out of view.
  final Widget? onColapsAppbar;

  final int limit;

  @override
  State<SmartTabListLoader<T>> createState() => _SmartTabListLoaderState<T>();
}

class _SmartTabListLoaderState<T> extends State<SmartTabListLoader<T>>
    with TickerProviderStateMixin {
  late Map<T, ScrollController> _scrollControllers;
  int _currentIndex = 0;

  Key _getKey(T tab) {
    return ValueKey(
      '${tab.hashCode}_${widget.gridConfig.hashCode}${widget.padding.hashCode}${widget.appbar.runtimeType}${widget.onColapsAppbar.runtimeType}',
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollControllers = {
      for (var tab in widget.tabs) tab.tab: ScrollController(),
    };
  }

  @override
  void didUpdateWidget(covariant SmartTabListLoader<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gridConfig != widget.gridConfig) {
      _update();
    }

    if (oldWidget.value != widget.value) {
      _switchToValueTab(fade: true);
    }

    if (oldWidget.tabs.length != widget.tabs.length) {
      _scrollControllers = {
        for (var tab in widget.tabs)
          tab.tab: _scrollControllers[tab.tab] ?? ScrollController(),
      };
    }
  }

  void _update() {
    if (mounted) setState(() {});
  }

  void _switchToValueTab({bool fade = true}) {
    final index = widget.tabs.indexWhere((t) => t.tab == widget.value);
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.tabs.length, (index) {
        final cfg = widget.tabs[index];
        final scrollController = _scrollControllers[cfg.tab]!;

        // Fade in/out using AnimatedOpacity, but widget stays in tree
        return IgnorePointer(
          ignoring: _currentIndex != index,
          child: AnimatedOpacity(
            opacity: _currentIndex == index ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.gridConfig == null
                ? _routeList(cfg, scrollController, index)
                : _routeGrid(cfg, scrollController, index),
          ),
        );
      }),
    );
  }

  SmartListLoader _routeList(
    SmartTabConfig<dynamic> cfg,
    ScrollController scrollController,
    int index,
  ) {
    return SmartListLoader(
      key: _getKey(cfg.tab),
      scrollController: scrollController,
      emptyWidget: cfg.emptyWidget ?? widget.emptyWidget,
      itemCount: cfg.itemCount,
      itemBuilder: (context, idx) {
        return widget.itemBuilder(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: idx,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
          idx,
        );
      },
      onLoadMore: (page) {
        widget.onLoadMore?.call(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: index,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
          page,
        );
      },
      onRefresh: () {
        widget.onRefresh?.call(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: index,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
        );
      },
      isLoading: cfg.isLoading,
      isLoadDone: cfg.isLoadDone,
      padding: widget.padding,
      appbar: widget.appbar,
      onColapsAppbar: widget.onColapsAppbar,
      limit: widget.limit,
    );
  }

  SmartStaggeredLoader _routeGrid(
    SmartTabConfig<dynamic> cfg,
    ScrollController scrollController,
    int index,
  ) {
    return SmartStaggeredLoader(
      key: _getKey(cfg.tab),
      emptyWidget: cfg.emptyWidget ?? widget.emptyWidget,
      scrollController: scrollController,
      gridConfig: cfg.gridConfig ?? widget.gridConfig,
      itemCount: cfg.itemCount,
      itemBuilder: (context, idx) {
        return widget.itemBuilder(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: idx,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
          idx,
        );
      },
      onLoadMore: (page) {
        widget.onLoadMore?.call(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: index,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
          page,
        );
      },
      onRefresh: () {
        widget.onRefresh?.call(
          SmartTabContext<T>(
            tab: cfg.tab,
            index: index,
            itemCount: cfg.itemCount,
            isLoading: cfg.isLoading,
            isLoadDone: cfg.isLoadDone,
          ),
        );
      },
      isLoading: cfg.isLoading,
      isLoadDone: cfg.isLoadDone,
      padding: widget.padding,
      appbar: widget.appbar,
      onColapsAppbar: widget.onColapsAppbar,
      limit: widget.limit,
    );
  }
}
