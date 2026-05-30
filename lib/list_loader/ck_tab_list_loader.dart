import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

class CkTabContext<T> {
  const CkTabContext({
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
      'CkTabContext(tab: $tab, index: $index, itemCount: $itemCount, '
      'isLoading: $isLoading, isLoadDone: $isLoadDone)';
}

class CkTabConfig<T> {
  const CkTabConfig({
    required this.tab,
    required this.itemCount,
    this.isLoading = false,
    this.isLoadDone = false,
    this.gridConfig,
    this.initalLoader,
    this.emptyWidget,
    this.subAppBar,
    this.subOnColapsAppbar,
    this.onReorder,
    this.seperator,
    this.listLoaderConfig,
    this.backgroundColor,
    this.physics,
  });

  final Widget? seperator;

  final T tab;

  final int itemCount;
  final bool isLoading;
  final bool isLoadDone;
  final Widget? initalLoader;
  final Widget? emptyWidget;
  final CkGridConfig? gridConfig;
  final Widget? subAppBar;
  final Widget? subOnColapsAppbar;
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Per-tab loader config. Overrides the global/parent CkListLoaderConfig.
  final CkListLoaderConfig? listLoaderConfig;

  /// Per-tab background color for the header delegate.
  final Color? backgroundColor;

  /// Per-tab scroll physics.
  final ScrollPhysics? physics;
}

// ignore: must_be_immutable
class CkTabListLoader<T> extends StatefulWidget {
  CkTabListLoader({
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
    this.onReorder,
    this.seperator,
    this.listLoaderConfig,
    this.backgroundColor = Colors.transparent,
    this.physics,
    super.key,
  }) : assert(tabs.isNotEmpty, 'tabs must not be empty');

  final Widget? seperator;

  final T value;

  final Widget? emptyWidget;

  final CkGridConfig? gridConfig;

  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Per-instance loader config passed to child loaders.
  /// Per-tab listLoaderConfig in CkTabConfig takes priority.
  final CkListLoaderConfig? listLoaderConfig;

  /// Background color for the header delegate. Defaults to transparent.
  final Color backgroundColor;

  /// Custom scroll physics passed to child loaders.
  final ScrollPhysics? physics;

  /// One config entry per tab — data/state only.
  List<CkTabConfig<T>> tabs;

  /// Builds each list item. Receives full tab context + the item index.
  final Widget Function(CkTabContext<T> ctx, int itemIndex) itemBuilder;

  /// Called once the internal [TabController] is ready.
  /// Use this to drive tab switching from your own appbar UI.
  /// e.g. controller.animateTo(index)
  final void Function(TabController controller)? onTabControllerReady;

  /// Called when the active tab changes.
  final void Function(CkTabContext<T> ctx)? onPageChange;

  /// Called when a tab needs to load the next page.
  final void Function(CkTabContext<T> ctx, int page)? onLoadMore;

  /// Called when a tab is pulled to refresh.
  final void Function(CkTabContext<T> ctx)? onRefresh;

  final bool isReverse;

  /// Shared across all tabs.
  final EdgeInsetsGeometry? padding;

  /// Main appbar — shown at top, scrolls away. Collapses into [onColapsAppbar].
  final Widget? appbar;

  /// Collapsed/sticky appbar — always pinned once [appbar] scrolls out of view.
  final Widget? onColapsAppbar;

  final int limit;

  @override
  State<CkTabListLoader<T>> createState() => _CkTabListLoaderState<T>();
}

class _CkTabListLoaderState<T> extends State<CkTabListLoader<T>>
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
  void didUpdateWidget(covariant CkTabListLoader<T> oldWidget) {
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
            child: cfg.gridConfig != null || widget.gridConfig != null
                ? _routeGrid(cfg, scrollController, index)
                : _routeList(cfg, scrollController, index),
          ),
        );
      }),
    );
  }

  CkListView _routeList(
    CkTabConfig<dynamic> cfg,
    ScrollController scrollController,
    int index,
  ) {
    return CkListView(
      key: _getKey(cfg.tab),
      scrollController: scrollController,
      emptyWidget: cfg.emptyWidget ?? widget.emptyWidget,
      itemCount: cfg.itemCount,
      itemBuilder: (context, idx) {
        return widget.itemBuilder(
          CkTabContext<T>(
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
          CkTabContext<T>(
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
          CkTabContext<T>(
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
      appbar: _buildAppbar(cfg),
      onColapsAppbar: _buildOncolupse(cfg),
      limit: widget.limit,
      onReorder: cfg.onReorder ?? widget.onReorder,
      seperator: cfg.seperator ?? widget.seperator,
      listLoaderConfig: cfg.listLoaderConfig ?? widget.listLoaderConfig,
      backgroundColor: cfg.backgroundColor ?? widget.backgroundColor,
      physics: cfg.physics ?? widget.physics,
    );
  }

  CkGridView _routeGrid(
    CkTabConfig<dynamic> cfg,
    ScrollController scrollController,
    int index,
  ) {
    return CkGridView(
      key: _getKey(cfg.tab),
      emptyWidget: cfg.emptyWidget ?? widget.emptyWidget,
      scrollController: scrollController,
      gridConfig: cfg.gridConfig ?? widget.gridConfig,
      itemCount: cfg.itemCount,
      itemBuilder: (context, idx) {
        return widget.itemBuilder(
          CkTabContext<T>(
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
          CkTabContext<T>(
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
          CkTabContext<T>(
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
      appbar: _buildAppbar(cfg),
      onColapsAppbar: _buildOncolupse(cfg),
      limit: widget.limit,
      onReorder: cfg.onReorder ?? widget.onReorder,
      listLoaderConfig: cfg.listLoaderConfig ?? widget.listLoaderConfig,
      backgroundColor: cfg.backgroundColor ?? widget.backgroundColor,
      physics: cfg.physics ?? widget.physics,
    );
  }

  Widget? _buildOncolupse(CkTabConfig<dynamic> cfg) {
    return cfg.subOnColapsAppbar == null
        ? widget.onColapsAppbar
        : widget.onColapsAppbar == null
        ? cfg.subOnColapsAppbar
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [widget.onColapsAppbar!, cfg.subOnColapsAppbar!],
          );
  }

  Widget? _buildAppbar(CkTabConfig<dynamic> cfg) {
    return cfg.subAppBar == null
        ? widget.appbar
        : widget.appbar == null
        ? cfg.subAppBar
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [widget.appbar!, cfg.subAppBar!],
          );
  }
}

/// @deprecated Use [CkTabContext] instead.
@Deprecated('Use CkTabContext instead')
typedef SmartTabContext<T> = CkTabContext<T>;

/// @deprecated Use [CkTabConfig] instead.
@Deprecated('Use CkTabConfig instead')
typedef SmartTabConfig<T> = CkTabConfig<T>;

/// @deprecated Use [CkTabListLoader] instead.
@Deprecated('Use CkTabListLoader instead')
typedef SmartTabListLoader<T> = CkTabListLoader<T>;
