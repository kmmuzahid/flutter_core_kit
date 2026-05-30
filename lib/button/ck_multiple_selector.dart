import 'package:core_kit/text/ck_text.dart';
import 'package:core_kit/utils/ck_screen_utils.dart';
import 'package:flutter/material.dart';

class CkMultipleSelector extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>)? onChange;
  final String? title;
  final bool showSearch;
  final TextStyle? itemTextStyle;
  final TextStyle? selectedItemTextStyle;
  final Color? checkColor;
  final Color? selectedColor;

  const CkMultipleSelector({
    super.key,
    required this.items,
    this.selectedItems = const [],
    this.onChange,
    this.title,
    this.showSearch = true,
    this.itemTextStyle,
    this.selectedItemTextStyle,
    this.checkColor,
    this.selectedColor,
  });

  @override
  _CkMultipleSelectorState createState() => _CkMultipleSelectorState();
}

class _CkMultipleSelectorState extends State<CkMultipleSelector> {
  late List<String> _selectedItems;
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(CkMultipleSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.selectedItems != widget.selectedItems) {
      setState(() {
        _selectedItems = List.from(widget.selectedItems);
        _filterItems();
      });
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
    });
  }

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
      widget.onChange?.call(List.from(_selectedItems));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.title!, style: theme.textTheme.titleLarge),
          ),
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = _selectedItems.contains(item);

              return CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: CkText(
                  text: item,
                  style: isSelected
                      ? widget.selectedItemTextStyle ??
                            TextStyle(
                              color: widget.selectedColor ?? theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            )
                      : widget.itemTextStyle ?? TextStyle(fontSize: 18.sp),
                ),
                value: isSelected,
                onChanged: (_) => _toggleItem(item),
                activeColor: widget.selectedColor ?? theme.primaryColor,
                checkColor: widget.checkColor ?? Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// @deprecated Use [CkMultipleSelector] instead.
@Deprecated('Use CkMultipleSelector instead')
typedef MultipleSelector = CkMultipleSelector;
