// ignore_for_file: avoid_annotating_with_dynamic

class DioResultExtractor {
  const DioResultExtractor({required this.data, required this.message});

  final dynamic Function(dynamic response) data;
  final String? Function(dynamic response) message;
}
