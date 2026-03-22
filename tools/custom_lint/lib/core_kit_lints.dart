import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;

PluginBase createPlugin() => _ProtectedLintPlugin();

class _ProtectedLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    _ProtectedLintRule(),
  ];
}

class _ProtectedLintRule extends DartLintRule {
  const _ProtectedLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'protected_lint',
    problemMessage:
        '🔒 {0} is @Protected(depth: {1}) but accessed from {2} folders away.',
    correctionMessage:
        'Please only use {0} within {1} folder levels of its definition at "{3}".',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleIdentifier((node) {
      final dynamic n = node;
      final element = n.staticElement;
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
      final dynamic d = node;
      final libraryElement = d.element?.importedLibrary;
      if (libraryElement == null) return;

      // Using dynamic to bypass resolution issues with Namespace.definedNames in some analyzer versions
      final dynamic namespace = libraryElement.exportNamespace;
      final Iterable<dynamic> definedNames = namespace.definedNames.values;
      final classes = definedNames.whereType<ClassElement>();
      for (final element in classes) {
        _check(
          resolver,
          reporter,
          element,
          node.offset,
          node.length,
          isImport: true,
        );
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
        classFile =
            e.firstFragment?.libraryFragment?.source?.fullName as String?;
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
      if (meta is! ElementAnnotation) continue;

      final element = meta.element;
      final name =
          element?.enclosingElement?.name ??
          element?.enclosingElement?.enclosingElement?.name;

      if (name == 'Protected') {
        protectedAnnotation = meta;
        break;
      }

      // Fallback for some analyzer versions
      if (meta.toSource().startsWith('@Protected')) {
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
      final dynamic r = reporter;
      if (isImport) {
        final code = LintCode(
          name: 'protected_import_lint',
          problemMessage:
              '🚫 Import of {0} is illegal. It is @Protected(depth: {1}) but accessed {2} folder(s) away.',
          errorSeverity: ErrorSeverity.ERROR,
        );
        r.reportErrorForOffset(code, offset, length, [
          element.name ?? '',
          depth,
          folderDiff,
        ]);
      } else {
        r.reportErrorForOffset(_code, offset, length, [
          element.name ?? '',
          depth,
          folderDiff,
          classFolder,
        ]);
      }
    }
  }

  int _folderDepth(String classFolder, String usageFolder) {
    if (p.equals(classFolder, usageFolder) ||
        p.isWithin(classFolder, usageFolder)) {
      return 1;
    }
    int diff = 1;
    String ancestor = classFolder;
    while (ancestor != p.dirname(ancestor)) {
      ancestor = p.dirname(ancestor);
      diff++;
      if (p.equals(ancestor, usageFolder) ||
          p.isWithin(ancestor, usageFolder)) {
        return diff;
      }
    }
    return diff;
  }
}
