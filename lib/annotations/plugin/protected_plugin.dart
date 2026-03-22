// analyzer_plugin/bin/protected_plugin.dart
import 'dart:isolate';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:core_kit/annotations/plugin/plugin.dart';

void main(List<String> args, SendPort sendPort) {
  var plugin = ProtectedAnalyzerPlugin(
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );
  ServerPluginStarter(plugin).start(sendPort);
}
