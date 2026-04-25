void main() {
  double sizeHeight = 800;
  double offsetDy = 600;
  double childSizeHeight = 200;
  double positionBottom = offsetDy; // because they pass offset.dy as bottom
  
  double y = sizeHeight - positionBottom - childSizeHeight;
  double bottomOfMenu = y + childSizeHeight;
  print("Bottom of menu: $bottomOfMenu"); // 800 - 600 = 200
  print("Top of widget: $offsetDy"); // 600
}
