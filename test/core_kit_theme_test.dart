import 'package:core_kit/core_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class TestConfigWithContext extends CoreKitConfig {
  @override
  String get imageBaseUrl => 'https://example.com';

  @override
  CkTransportConfig get ckTransportConfig => CkTransportConfig(
    baseUrl: 'https://example.com',
    refreshTokenEndpoint: '/refresh',
  );

  @override
  int get splashDelayMs => 0;

  @override
  CkInputConfig? get inputConfig => CkInputConfig(
    borderColor: Theme.of(context).primaryColor,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  );
}

class ThemeSwitcherTest extends StatefulWidget {
  final CoreKitConfig config;
  const ThemeSwitcherTest({super.key, required this.config});

  @override
  State<ThemeSwitcherTest> createState() => _ThemeSwitcherTestState();
}

class _ThemeSwitcherTestState extends State<ThemeSwitcherTest> {
  final _navKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoreKit(
      navigatorKey: _navKey,
      config: widget.config,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: Column(
          children: [
            const CkTextField(validationType: CkValidationType.notRequired),
            ElevatedButton(onPressed: toggleTheme, child: const Text('Toggle')),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'CoreKit config inputConfig with context works with theme and theme switching',
    (tester) async {
      final config = TestConfigWithContext();

      await tester.pumpWidget(ThemeSwitcherTest(config: config));
      await tester.pumpAndSettle();

      // Initial light theme
      expect(coreKitInstance.inputConfig.borderColor, Colors.blue);
      expect(coreKitInstance.inputConfig.backgroundColor, Colors.white);

      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.fillColor, Colors.white);
      var enabledBorder =
          textField.decoration?.enabledBorder as OutlineInputBorder;
      expect(enabledBorder.borderSide.color, Colors.blue);

      // Switch to dark theme
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Dark theme should update inputConfig
      expect(coreKitInstance.inputConfig.borderColor, Colors.purple);
      expect(coreKitInstance.inputConfig.backgroundColor, Colors.black);

      // The text field widget itself should also reflect the new dark theme colors!
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.fillColor, Colors.black);
      enabledBorder = textField.decoration?.enabledBorder as OutlineInputBorder;
      expect(enabledBorder.borderSide.color, Colors.purple);

      // Drain any background storage timeout timer
      await tester.pump(const Duration(seconds: 4));
    },
  );
}
