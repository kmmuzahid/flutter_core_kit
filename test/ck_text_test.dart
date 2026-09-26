import 'package:core_kit/core_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    navigatorKey: coreKitInstance.navigatorKey,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    coreKitInstance.navigatorKey = GlobalKey<NavigatorState>();
  });

  group('CkText decimalPlaces Configuration Tests', () {
    testWidgets(
      'default decimalPlaces is 2 and rounds numbers to 2 decimal places',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(const CkText(text: 'Price: 12.345 USD')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Price: 12.35 USD'), findsOneWidget);
        expect(find.text('Price: 12.345 USD'), findsNothing);
      },
    );

    testWidgets('decimalPlaces: 2 explicitly behaves identically to default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const CkText(text: 'Amount: 99.999', decimalPlaces: 2)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amount: 100.00'), findsOneWidget);
    });

    testWidgets(
      'decimalPlaces: 1 rounds to 1 decimal place (ratings / metrics)',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(text: 'Rating: 4.89 / 5.0', decimalPlaces: 1),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Rating: 4.9 / 5.0'), findsOneWidget);
      },
    );

    testWidgets('decimalPlaces: 0 rounds to nearest integer', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CkText(text: 'Weight: 12.345 kg', decimalPlaces: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weight: 12 kg'), findsOneWidget);
    });

    testWidgets('decimalPlaces: 0 rounds up when >= .5', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const CkText(text: 'Score: 12.789', decimalPlaces: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Score: 13'), findsOneWidget);
    });

    testWidgets('decimalPlaces: 3 formats to 3 decimal places', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const CkText(text: 'Ratio: 3.14159', decimalPlaces: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ratio: 3.142'), findsOneWidget);
    });

    testWidgets(
      'decimalPlaces: null completely disables number formatting (preserves version strings & codes)',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(
              text: 'App version v1.0.4 at GPS 37.7749, -122.4194',
              decimalPlaces: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('App version v1.0.4 at GPS 37.7749, -122.4194'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'decimalPlaces formats multiple floating-point numbers in a single string',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(text: 'Range: 1.234 to 5.678', decimalPlaces: 2),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Range: 1.23 to 5.68'), findsOneWidget);
      },
    );
  });

  group('CkText Rendering Modes with decimalPlaces', () {
    testWidgets('isDescription: true formats numbers correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CkText(
            text: 'Item costs 45.678 dollars',
            isDescription: true,
            decimalPlaces: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item costs 45.7 dollars'), findsOneWidget);
    });

    testWidgets(
      'maxLines > 1 with preventScaling: true formats numbers correctly',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(
              text: 'Line 1: 10.456\nLine 2: 20.789',
              maxLines: 2,
              preventScaling: true,
              decimalPlaces: 2,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Line 1: 10.46\nLine 2: 20.79'), findsOneWidget);
      },
    );

    testWidgets(
      'maxLines > 1 with preventScaling: false formats numbers correctly in adaptive mode',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const SizedBox(
              width: 300,
              child: CkText(
                text: 'Adaptive 15.999',
                maxLines: 2,
                preventScaling: false,
                decimalPlaces: 2,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Adaptive 16.00'), findsOneWidget);
      },
    );

    testWidgets('preventScaling: true single-line formats numbers correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CkText(
            text: 'Fixed 99.456',
            preventScaling: true,
            decimalPlaces: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fixed 99.5'), findsOneWidget);
    });

    testWidgets('HTML content formats numbers when decimalPlaces is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CkText(text: '<p>Balance: 12.345</p>', decimalPlaces: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HtmlWidget), findsOneWidget);
      final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
      expect(htmlWidget.html, '<p>Balance: 12.35</p>');
    });

    testWidgets(
      'HTML content leaves text untouched when decimalPlaces is null',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(text: '<p>Release v2.0.1</p>', decimalPlaces: null),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HtmlWidget), findsOneWidget);
        final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
        expect(htmlWidget.html, '<p>Release v2.0.1</p>');
      },
    );

    testWidgets(
      'renders prefix, suffix, and border without altering existing functionality',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CkText(
              text: 'Total: 10.999',
              enableBorder: true,
              borderColor: Colors.blue,
              backgroundColor: Colors.white,
              preffix: Icon(Icons.monetization_on),
              suffix: Icon(Icons.check),
              decimalPlaces: 2,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Total: 11.00'), findsOneWidget);
        expect(find.byIcon(Icons.monetization_on), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );
  });
}
