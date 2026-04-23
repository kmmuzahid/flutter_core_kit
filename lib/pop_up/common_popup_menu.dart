import 'package:core_kit/core_kit_internal.dart';
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';

class CommonPopupMenuTriggerProperty<T> {
  final T? value;
  final bool isOpen;

  CommonPopupMenuTriggerProperty({this.value, required this.isOpen});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommonPopupMenuTriggerProperty &&
        other.value == value &&
        other.isOpen == isOpen;
  }

  @override
  int get hashCode {
    return value.hashCode ^ isOpen.hashCode;
  }
}

class CommonPopupMenuProperty<T> {
  final T? item;
  final bool isSelected;

  CommonPopupMenuProperty({this.item, required this.isSelected});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommonPopupMenuProperty &&
        other.item == item &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return item.hashCode ^ isSelected.hashCode;
  }
}

class CommonPopupMenu<T> extends StatefulWidget {
  const CommonPopupMenu({
    required this.items,
    required this.onItemSelected,
    required this.itemBuilder,
    required this.triggerBuilder,
    super.key,
    this.initialItem,
    this.menuItemAlignment,
    this.isSeparated = false,
    this.borderColor,
    this.menuBackgroundColor,
    this.itemPadding,
    this.borderRadius,
    this.menuWidth,
  });

  final List<T> items;
  final void Function(T selectedItem) onItemSelected;
  final T? initialItem;
  final Widget Function(CommonPopupMenuProperty<T> property) itemBuilder;
  final Widget Function(CommonPopupMenuTriggerProperty<T> property)
  triggerBuilder;

  final AlignmentGeometry? menuItemAlignment;
  final bool isSeparated;
  final Color? borderColor;
  final Color? menuBackgroundColor;
  final EdgeInsets? itemPadding;
  final double? borderRadius;
  final double? menuWidth;

  @override
  State<CommonPopupMenu<T>> createState() => _SelectablePopupMenuState<T>();
}

class _SelectablePopupMenuState<T> extends State<CommonPopupMenu<T>> {
  T? selectedItem;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedItem =
        widget.initialItem ??
        (widget.items.isNotEmpty ? widget.items.first : null);
  }

  Future<void> _showPopupMenu(BuildContext context, GlobalKey key) async {
    final button = key.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

    setState(() {
      isOpen = true;
    });

    final selected = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      color: widget.menuBackgroundColor ?? coreKitInstance.surfaceBG,
      elevation: 1,
      shadowColor: coreKitInstance.outlineColor,
      shape: widget.borderColor != null || widget.borderRadius != null
          ? RoundedRectangleBorder(
              side: widget.borderColor != null
                  ? BorderSide(color: widget.borderColor!)
                  : BorderSide.none,
              borderRadius: widget.borderRadius != null
                  ? BorderRadius.circular(widget.borderRadius!)
                  : BorderRadius.circular(8.r),
            )
          : null,
      items: [
        for (int i = 0; i < widget.items.length; i++) ...[
          _itemBuilder(i),
          if (widget.isSeparated && i < widget.items.length - 1)
            const PopupMenuDivider(),
        ],
      ],
    );

    setState(() {
      isOpen = false;
      if (selected != null) {
        selectedItem = selected;
      }
    });

    if (selected != null) {
      widget.onItemSelected(selected);
    }
  }

  PopupMenuItem<T> _itemBuilder(int index) {
    final item = widget.items[index];
    return PopupMenuItem<T>(
      value: item,
      padding: widget.itemPadding,
      child: Container(
        constraints: widget.menuWidth != null
            ? BoxConstraints(minWidth: widget.menuWidth!)
            : null,
        alignment: widget.menuItemAlignment,
        child: widget.itemBuilder(
          CommonPopupMenuProperty(item: item, isSelected: selectedItem == item),
        ),
      ),
    );
  }

  final GlobalKey _triggerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      onTap: () => _showPopupMenu(context, _triggerKey),
      child: widget.triggerBuilder(
        CommonPopupMenuTriggerProperty(value: selectedItem, isOpen: isOpen),
      ),
    );
  }
}
