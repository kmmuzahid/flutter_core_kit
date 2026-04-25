import 'package:flutter/material.dart';

class _PopupMenuLayoutDelegate extends SingleChildLayoutDelegate {
  _PopupMenuLayoutDelegate(this.position, this.selectedItemOffset, this.textDirection);

  final RelativeRect position;
  final double? selectedItemOffset;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y = position.top;
    if (selectedItemOffset != null) {
      y = y + selectedItemOffset!;
    }
    double bottom = y + childSize.height;
    if (bottom > size.height) {
      y = size.height - childSize.height;
    }
    if (y < 0) {
      y = 0;
    }
    return Offset(0.0, y);
  }
  
  @override
  bool shouldRelayout(_PopupMenuLayoutDelegate oldDelegate) {
    return false;
  }
}

void main() {
  print("hello");
}
