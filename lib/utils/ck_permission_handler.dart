import 'package:core_kit/core_kit_internal.dart';

/// Legacy permission handler wrapper kept for backward compatibility.
///
/// Please use [CkPermission] or `Permission.ensure()` for modern usage:
/// ```dart
/// final status = await CkPermission.camera.ensure();
/// // or
/// final status = await Permission.camera.ensure();
/// ```
@Deprecated('Use CkPermission or Permission.ensure() extension instead. Example: CkPermission.camera.ensure() or Permission.camera.ensure()')
class CkPermissionHandler {
  const CkPermissionHandler({required this.permission});
  final Permission permission;

  /// Checks and requests the permission.
  Future<bool> getStatus() async {
    return CkPermission(permission).ensure();
  }
}
