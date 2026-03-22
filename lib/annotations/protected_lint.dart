// lib/src/lints/protected_lint.dart
import 'package:linter/src/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class ProtectedLintRule extends LintRule {
  ProtectedLintRule()
      : super(
          name: 'protected_lint',
          description: 'Enforce folder-level access for classes annotated with @Protected',
          details:
              'Classes annotated with @Protected(depth:X) can only be used within allowed folder depth.',
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    final visitor = _ProtectedVisitor(this, context);
    registry.addSimpleIdentifier(this, visitor);
    registry.addNamedType(this, visitor);
  }
}

class _ProtectedVisitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _ProtectedVisitor(this.rule, this.context);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.staticElement is ClassElement) {
      _checkElement(node.staticElement as ClassElement, node);
    }
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.element is ClassElement) {
      _checkElement(node.element as ClassElement, node);
    }
  }

  void _checkElement(ClassElement element, AstNode node) {
    File('C:\\Users\\kmmuz\\Documents\\flutter_project\\riverpod_tamplates\\plugin_log.txt')
        .writeAsStringSync('Visiting ${element.name} from current context\\n', mode: FileMode.append);

    // Ignore usages in the class's own file
    final usageSource = context.currentUnit.unit.declaredElement?.source;
    if (usageSource == null || element.source.fullName == usageSource.fullName) {
      return;
    }

    ElementAnnotation? annotation;
    for (final m in element.metadata) {
      // Depending on analyzer version, might need enclosingElement3 or just enclosingElement
      final name = m.element?.enclosingElement?.name; 
      if (name == 'Protected') {
        annotation = m;
        break;
      }
    }

    if (annotation == null) return;

    final depth = _getDepth(annotation);
    final classFolder = p.dirname(element.source.fullName);
    final usageFolder = p.dirname(usageSource.fullName);

    final folderDiff = _computeFolderDepth(classFolder, usageFolder);
    if (folderDiff > depth) {
      rule.reportLintForToken(
        node.beginToken,
        arguments: ['Used outside allowed folder depth: $folderDiff > $depth'],
      );
    }
  }

  int _getDepth(ElementAnnotation annotation) {
    final value = annotation.computeConstantValue();
    if (value == null) return 1;
    return value.getField('depth')?.toIntValue() ?? 1;
  }

  int _computeFolderDepth(String classPath, String usagePath) {
    final classFolder = p.dirname(classPath);
    final usageFolder = p.dirname(usagePath);
    
    if (p.isWithin(classFolder, usageFolder) || classFolder == usageFolder) {
      return 1;
    }
    
    int diff = 1;
    String ancestor = classFolder;
    while (ancestor != p.dirname(ancestor)) {
      ancestor = p.dirname(ancestor);
      diff++;
      if (p.isWithin(ancestor, usageFolder) || ancestor == usageFolder) {
        return diff;
      }
    }
    return diff;
  }
}