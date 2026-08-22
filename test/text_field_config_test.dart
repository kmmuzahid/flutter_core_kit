import 'package:core_kit/core_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() {
    coreKitInstance.navigatorKey = GlobalKey<NavigatorState>();
    coreKitInstance.inputConfig = const CkInputConfig();
  });

  group('CkInputConfig errorColor tests', () {
    test('default errorColor is Colors.red', () {
      const config = CkInputConfig();
      expect(config.errorColor.toARGB32(), Colors.red.toARGB32());
    });

    test('custom errorColor in constructor', () {
      const config = CkInputConfig(errorColor: Colors.deepOrange);
      expect(config.errorColor.toARGB32(), Colors.deepOrange.toARGB32());
    });

    test('copyWith updates errorColor', () {
      const config = CkInputConfig();
      final updated = config.copyWith(errorColor: Colors.purple);
      expect(updated.errorColor.toARGB32(), Colors.purple.toARGB32());
      expect(updated.borderWidth, 1.2);
    });

    test('copyWith preserves errorColor when not specified', () {
      const config = CkInputConfig(errorColor: Colors.amber);
      final updated = config.copyWith(borderRadius: 16);
      expect(updated.errorColor.toARGB32(), Colors.amber.toARGB32());
      expect(updated.borderRadius, 16);
    });
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      navigatorKey: coreKitInstance.navigatorKey,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('CkTextField Border & errorColor Widget Tests', () {
    testWidgets('CkTextField applies errorColor and matching borderRadius to errorBorder and focusedErrorBorder', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CkTextField(
            validationType: CkValidationType.validateRequired,
            borderRadius: 15,
            borderColor: Colors.grey,
            errorColor: Colors.amber,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      // Verify errorBorder
      expect(decoration.errorBorder, isA<OutlineInputBorder>());
      final errorBorder = decoration.errorBorder as OutlineInputBorder;
      expect(errorBorder.borderSide.color.toARGB32(), Colors.amber.toARGB32());
      expect(errorBorder.borderRadius, BorderRadius.circular(15.r));

      // Verify focusedErrorBorder
      expect(decoration.focusedErrorBorder, isA<OutlineInputBorder>());
      final focusedErrorBorder = decoration.focusedErrorBorder as OutlineInputBorder;
      expect(focusedErrorBorder.borderSide.color.toARGB32(), Colors.amber.toARGB32());
      expect(focusedErrorBorder.borderRadius, BorderRadius.circular(15.r));

      // Verify enabledBorder has the same radius
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      final enabledBorder = decoration.enabledBorder as OutlineInputBorder;
      expect(enabledBorder.borderSide.color.toARGB32(), Colors.grey.toARGB32());
      expect(enabledBorder.borderRadius, BorderRadius.circular(15.r));

      // Verify disabledBorder and border have the same radius
      expect(decoration.disabledBorder, isA<OutlineInputBorder>());
      final disabledBorder = decoration.disabledBorder as OutlineInputBorder;
      expect(disabledBorder.borderRadius, BorderRadius.circular(15.r));

      expect(decoration.border, isA<OutlineInputBorder>());
      final baseBorder = decoration.border as OutlineInputBorder;
      expect(baseBorder.borderRadius, BorderRadius.circular(15.r));
    });

    testWidgets('CkTextField underline borderType preserves underline shape across all error borders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CkTextField(
            validationType: CkValidationType.validateRequired,
            borderType: CkBorderType.underline,
            borderRadius: 8,
            errorColor: Colors.pink,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      expect(decoration.errorBorder, isA<UnderlineInputBorder>());
      final errorBorder = decoration.errorBorder as UnderlineInputBorder;
      expect(errorBorder.borderSide.color.toARGB32(), Colors.pink.toARGB32());
      expect(errorBorder.borderRadius, BorderRadius.circular(8.r));

      expect(decoration.focusedErrorBorder, isA<UnderlineInputBorder>());
      final focusedErrorBorder = decoration.focusedErrorBorder as UnderlineInputBorder;
      expect(focusedErrorBorder.borderSide.color.toARGB32(), Colors.pink.toARGB32());
      expect(focusedErrorBorder.borderRadius, BorderRadius.circular(8.r));
    });
  });

  group('CkMultilineTextField Border & errorColor Widget Tests', () {
    testWidgets('CkMultilineTextField applies errorColor and matching radius to error borders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CkMultilineTextField(
            validationType: CkValidationType.validateRequired,
            borderRadius: 20,
            errorColor: Colors.teal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      expect(decoration.errorBorder, isA<OutlineInputBorder>());
      final errorBorder = decoration.errorBorder as OutlineInputBorder;
      expect(errorBorder.borderSide.color.toARGB32(), Colors.teal.toARGB32());
      expect(errorBorder.borderRadius, BorderRadius.circular(20.r));

      expect(decoration.focusedErrorBorder, isA<OutlineInputBorder>());
      final focusedErrorBorder = decoration.focusedErrorBorder as OutlineInputBorder;
      expect(focusedErrorBorder.borderSide.color.toARGB32(), Colors.teal.toARGB32());
      expect(focusedErrorBorder.borderRadius, BorderRadius.circular(20.r));
    });
  });

  group('CkSearch Border & errorColor Widget Tests', () {
    testWidgets('CkSearch applies errorColor and matching radius to error borders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CkSearch(
            borderRadius: 14,
            errorColor: Colors.indigo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      expect(decoration.errorBorder, isA<OutlineInputBorder>());
      final errorBorder = decoration.errorBorder as OutlineInputBorder;
      expect(errorBorder.borderSide.color.toARGB32(), Colors.indigo.toARGB32());
      expect(errorBorder.borderRadius, BorderRadius.circular(14.r));

      expect(decoration.focusedErrorBorder, isA<OutlineInputBorder>());
      final focusedErrorBorder = decoration.focusedErrorBorder as OutlineInputBorder;
      expect(focusedErrorBorder.borderSide.color.toARGB32(), Colors.indigo.toARGB32());
      expect(focusedErrorBorder.borderRadius, BorderRadius.circular(14.r));
    });
  });
}
