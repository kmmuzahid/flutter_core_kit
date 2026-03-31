// // lib/annotations/plugin/plugin.dart
// import 'dart:async';
// import 'package:analyzer/dart/analysis/analysis_context.dart';
// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/visitor.dart';
// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer_plugin/plugin/plugin.dart';
// import 'package:analyzer_plugin/protocol/protocol_common.dart';
// import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// import 'package:path/path.dart' as p;

// class ProtectedAnalyzerPlugin extends ServerPlugin {
//   ProtectedAnalyzerPlugin({required super.resourceProvider});

//   @override
//   String get name => 'protected_plugin';

//   @override
//   String get version => '1.0.0';

//   @override
//   List<String> get fileGlobsToAnalyze => ['**/*.dart'];

//   @override
//   Future<void> analyzeFile({
//     required AnalysisContext analysisContext,
//     required String path,
//   }) async {
//     if (!path.endsWith('.dart')) return;

//     final result = await analysisContext.currentSession.getResolvedUnit(path);
//     if (result is! ResolvedUnitResult) return;

//     final collector = _ProtectedUsageCollector(result);
//     result.unit.accept(collector);

//     if (collector.errors.isEmpty) return;

//     channel.sendNotification(
//       AnalysisErrorsParams(path, collector.errors).toNotification(),
//     );
//   }

//   @override
//   Future<EditGetAssistsResult> handleEditGetAssists(
//     EditGetAssistsParams parameters,
//   ) async {
//     return EditGetAssistsResult(const <PrioritizedSourceChange>[]);
//   }
// }

// class _ProtectedUsageCollector extends RecursiveAstVisitor<void> {
//   final ResolvedUnitResult result;
//   final List<AnalysisError> errors = [];

//   _ProtectedUsageCollector(this.result);

//   @override
//   void visitSimpleIdentifier(SimpleIdentifier node) {
//     super.visitSimpleIdentifier(node);
//     final element = node.staticElement;
//     if (element is ClassElement) {
//       _check(element, node.offset, node.length);
//     }
//   }

//   @override
//   void visitNamedType(NamedType node) {
//     super.visitNamedType(node);
//     final element = node.element;
//     if (element is ClassElement) {
//       _check(element, node.offset, node.length);
//     }
//   }

//   void _check(ClassElement element, int offset, int length) {
//     final usageFile = result.path;
//     final classFile = element.source.fullName;

//     // Skip checking within the class's own file
//     if (usageFile == classFile) return;

//     // Look for @Protected annotation
//     ElementAnnotation? protectedAnnotation;
//     for (final meta in element.metadata) {
//       final annotationName =
//           meta.element?.enclosingElement?.name ??
//           meta.element?.enclosingElement?.enclosingElement?.name;
//       if (annotationName == 'Protected') {
//         protectedAnnotation = meta;
//         break;
//       }
//     }
//     if (protectedAnnotation == null) return;

//     // Get the depth value
//     final constValue = protectedAnnotation.computeConstantValue();
//     final depth = constValue?.getField('depth')?.toIntValue() ?? 1;

//     // Compute folder distance
//     final classFolder = p.dirname(classFile);
//     final usageFolder = p.dirname(usageFile);

//     final folderDiff = _computeFolderDepth(classFolder, usageFolder);

//     if (folderDiff > depth) {
//       final location = Location(
//         usageFile,
//         offset,
//         length,
//         result.lineInfo.getLocation(offset).lineNumber,
//         result.lineInfo.getLocation(offset).columnNumber,
//         endLine: result.lineInfo.getLocation(offset + length).lineNumber,
//         endColumn: result.lineInfo.getLocation(offset + length).columnNumber,
//       );

//       errors.add(
//         AnalysisError(
//           AnalysisErrorSeverity.WARNING,
//           AnalysisErrorType.LINT,
//           location,
//           '${element.name} is @Protected(depth: $depth) '
//               'but accessed $folderDiff folder level(s) away.',
//           'protected_lint',
//           correction:
//               'Only use ${element.name} within $depth folder level(s) of its definition.',
//           hasFix: false,
//         ),
//       );
//     }
//   }

//   int _computeFolderDepth(String classFolder, String usageFolder) {
//     if (p.equals(classFolder, usageFolder) ||
//         p.isWithin(classFolder, usageFolder)) {
//       return 1;
//     }

//     int diff = 1;
//     String ancestor = classFolder;
//     while (ancestor != p.dirname(ancestor)) {
//       ancestor = p.dirname(ancestor);
//       diff++;
//       if (p.equals(ancestor, usageFolder) ||
//           p.isWithin(ancestor, usageFolder)) {
//         return diff;
//       }
//     }
//     return diff;
//   }
// }
