/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05
 * @Email: km.muzahid@gmail.com
 */

import 'package:core_kit/app_bar/common_app_bar.dart';
import 'package:core_kit/button/common_button.dart';
import 'package:core_kit/button/common_radio_group.dart';
import 'package:core_kit/city_state/common_city_dropdown.dart';
import 'package:core_kit/city_state/common_state_dropdown.dart';
import 'package:core_kit/commonTabBar/common_tab_bar.dart';
import 'package:core_kit/image/common_image.dart';
import 'package:core_kit/image/image_picker/common_image_picker.dart';
import 'package:core_kit/image/image_picker/common_multi_image_picker.dart';
import 'package:core_kit/initizalizer.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/text/common_rich_text.dart';
import 'package:core_kit/text/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUpAll(() {});

  Future<void> pumpWidget(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              CoreKit.instance.init(
                context: context,
                backgroundColor: Colors.white,
                back: () {
                  navigatorKey.currentState?.pop();
                },
                imageBaseUrl: 'https://',
                navigatorKey: navigatorKey,
                primaryColor: Colors.white,
                onPrimaryColor: Colors.white,
                secondaryColor: Colors.white,
                outlineColor: Colors.white,
                surfaceBG: Colors.white,
                dioServiceConfig: DioServiceConfig(
                  baseUrl: 'https://jsonplaceholder.typicode.com',
                  refreshTokenEndpoint: 'https://jsonplaceholder.typicode.com',
                  onLogout: () {},
                  enableDebugLogs: true,
                ),
                tokenProvider: TokenProvider(
                  accessToken: () => 'accessToken',
                  refreshToken: () => 'refreshToken',
                  updateTokens: (accessToken, refreshToken) async {},
                  clearTokens: () async {},
                ),
              );
              return child;
            },
          ),
        ),
      ),
    );
  }

  testWidgets('CommonAppBar renders', (tester) async {
    await pumpWidget(tester, CommonAppBar(title: 'CommonAppBar'));

    expect(find.text('CommonAppBar'), findsOneWidget);
  });

  testWidgets('CommonButton renders', (tester) async {
    await pumpWidget(tester, CommonButton(titleText: 'CommonButton'));

    expect(find.text('CommonButton'), findsOneWidget);
  });

  testWidgets('CommonRadioGroup renders', (tester) async {
    await pumpWidget(tester, CommonRadioGroup(options: {'1': '1', '2': '2'}));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('CommonText renders', (tester) async {
    await pumpWidget(tester, const CommonText(text: 'Hello CommonText'));

    expect(find.text('Hello CommonText'), findsOneWidget);
  });

  testWidgets('CommonRichText renders', (tester) async {
    await pumpWidget(
      tester,
      CommonRichText(
        richTextContent: [CommonRichTextSpan(textSpan: const TextSpan(text: 'Hello CommonText'))],
      ),
    );

    expect(find.text('Hello CommonText'), findsOneWidget);
  });

  testWidgets('CommonStateDropdown renders', (tester) async {
    await pumpWidget(
      tester,
      CommonStateDropdown(countryName: 'United States of America', onChanged: (_) {}),
    );

    expect(find.byType(CommonStateDropdown), findsOneWidget);
  });

  testWidgets('CommonCityDropdown renders', (tester) async {
    await pumpWidget(tester, CommonCityDropDown(onChange: (_) {}));

    expect(find.byType(CommonCityDropDown), findsOneWidget);
  });

  testWidgets('CommonImage renders', (tester) async {
    await pumpWidget(tester, const CommonImage(src: 'picsum.photos/200/300'));

    expect(find.byType(CommonImage), findsOneWidget);
  });

  testWidgets('CommonImagePicker renders', (tester) async {
    await pumpWidget(tester, const CommonImagePicker());

    expect(find.byType(CommonImagePicker), findsOneWidget);
  });

  testWidgets('CommonMultiImagePickerFormField renders', (tester) async {
    await pumpWidget(tester, CommonMultiImagePickerFormField());

    expect(find.byType(CommonMultiImagePickerFormField), findsOneWidget);
  });

  testWidgets('CommonTabBar renders', (tester) async {
    await pumpWidget(
      tester,
      CommonTabBar(tabs: ['Tab 1', 'Tab 2'], tabViews: [Container(), Container()]),
    );

    expect(find.byType(CommonTabBar), findsOneWidget);
  });
}
