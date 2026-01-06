import 'package:core_kit/initializer.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonDraggableBottomSheet extends StatefulWidget {
  const CommonDraggableBottomSheet({
    required this.collapsedContent,
    required this.expandedContent,
    this.initialChildSize = 0.15,
    this.minChildSize = 0.15,
    this.maxChildSize = 0.4,
    super.key,
  });

  final Widget collapsedContent;
  final Widget expandedContent;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  State<CommonDraggableBottomSheet> createState() => _CommonDraggableBottomSheetState();
}

class _CommonDraggableBottomSheetState extends State<CommonDraggableBottomSheet> {
  late DraggableScrollableController _draggableController;
  double _currentSize = 0.15;

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController()..addListener(_onSizeChange);
  }

  void _onSizeChange() {
    final newSize = _draggableController.size;
    if ((newSize - _currentSize).abs() >= 0.01) {
      setState(() => _currentSize = newSize);
    }
  }

  @override
  void dispose() {
    _draggableController
      ..removeListener(_onSizeChange)
      ..dispose();
    super.dispose();
  }

  Widget _buildHandler() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        height: 4.h,
        width: 30.w,
        decoration: BoxDecoration(
          color: CoreKit.instance.primaryColor,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: CoreKit.instance.outlineColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Column(
            children: [
              10.height,
              _buildHandler(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _currentSize < widget.maxChildSize * .7
                        ? widget.collapsedContent
                        : widget.expandedContent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
