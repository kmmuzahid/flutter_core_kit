// ignore_for_file: avoid_annotating_with_dynamic

class CkResponseExtractor {
  CkResponseExtractor({
    required this.data,
    required this.message,
    dynamic Function(dynamic response)? meta,
  }) : meta = meta ?? defaultMeta;

  final dynamic Function(dynamic response) data;
  final String? Function(dynamic response) message;

  /// Optional payload (pagination, etc.). `null` when the key is absent.
  final dynamic Function(dynamic response) meta;

  /// Default: returns `response['meta']` when present, otherwise `null`.
  static dynamic defaultMeta(dynamic response) {
    if (response is Map && response.containsKey('meta')) {
      return response['meta'];
    }
    return null;
  }

  static bool readSuccess(dynamic response) {
    if (response is Map) {
      return response['success'] == true;
    }
    return false;
  }
}
