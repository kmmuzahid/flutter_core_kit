// lib/src/annotations/protected.dart
/// Marks a class as protected within folder depth.
/// - depth = 1 → same folder
/// - depth = 2 → include parent folder
/// - depth = 3 → include grandparent folder, etc.
class Protected {
  final int depth;
  const Protected([this.depth = 1]);
}