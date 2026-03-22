import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;

/// Entry point for custom_lint
PluginBase createPlugin() => _ProtectedLintPlugin();

class _ProtectedLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        _ProtectedLintRule(),
      ];
}

class _ProtectedLintRule extends DartLintRule {
  _ProtectedLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'protected_lint',
    problemMessage: '{0} is annotated @Protected(depth: {1}) but is accessed from {2} folder level(s) away.',
    correctionMessage: 'Only access {0} within {1} folder level(s) of its definition at "{3}".',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleIdentifier((node) {
      final element = node.staticElement;
      if (element is ClassElement) {
        _check(resolver, reporter, element, node.offset, node.length);
      }
    });

    context.registry.addNamedType((node) {
      final element = node.element;
      if (element is ClassElement) {
        _check(resolver, reporter, element, node.offset, node.length);
      }
    });

    context.registry.addImportDirective((node) {
      final libraryElement = node.element?.importedLibrary;
      if (libraryElement == null) return;

      final classes = libraryElement.exportNamespace.definedNames.values.whereType<ClassElement>();
      for (final element in classes) {
        _check(resolver, reporter, element, node.offset, node.length, isImport: true);
      }
    });
  }

  void _check(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    ClassElement element,
    int offset,
    int length, {
    bool isImport = false,
  }) {
    final usageFile = resolver.path;

    // Resiliently get the class file path
    final dynamic e = element;
    String? classFile;
    try {
      classFile = e.source?.fullName as String?;
    } catch (_) {}
    if (classFile == null) {
      try {
        classFile = e.librarySource?.fullName as String?;
      } catch (_) {}
    }
    if (classFile == null) {
      try {
        classFile = e.firstFragment?.libraryFragment?.source?.fullName as String?;
      } catch (_) {}
    }
    if (classFile == null) {
      try {
        classFile = e.library?.source?.fullName as String?;
      } catch (_) {}
    }

    if (classFile == null) return;

    // Skip usages in the same file
    if (usageFile == classFile) return;

    // Look for @Protected annotation
    ElementAnnotation? protectedAnnotation;
    dynamic annots;
    try {
      annots = (element.metadata as dynamic).annotations;
    } catch (_) {
      annots = element.metadata;
    }

    for (final meta in annots) {
      final sourceStr = meta.toSource();
      if (sourceStr.startsWith('@Protected')) {
        protectedAnnotation = meta;
        break;
      }
    }

    if (protectedAnnotation == null) return;

    final constValue = protectedAnnotation.computeConstantValue();
    final depth = constValue?.getField('depth')?.toIntValue() ?? 1;

    final classFolder = p.dirname(classFile);
    final usageFolder = p.dirname(usageFile);
    final folderDiff = _folderDepth(classFolder, usageFolder);

    if (folderDiff > depth) {
      if (isImport) {
        reporter.reportErrorForOffset(
          LintCode(
            name: 'protected_import_lint',
            problemMessage: 'Importing {0} is illegal. It is annotated @Protected(depth: {1}) but accessed {2} folder level(s) away.',
            errorSeverity: ErrorSeverity.ERROR,
          ),
          offset,
          length,
          [element.name, depth, folderDiff],
        );
      } else {
        reporter.reportErrorForOffset(
          _code,
          offset,
          length,
          [element.name, depth, folderDiff, classFolder],
        );
      }
    }
  }

  int _folderDepth(String classFolder, String usageFolder) {
    if (p.equals(classFolder, usageFolder) || p.isWithin(classFolder, usageFolder)) {
      return 1;
    }
    int diff = 1;
    String ancestor = classFolder;
    while (ancestor != p.dirname(ancestor)) {
      ancestor = p.dirname(ancestor);
      diff++;
      if (p.equals(ancestor, usageFolder) || p.isWithin(ancestor, usageFolder)) {
        return diff;
      }
    }
    return diff;
  }
}
