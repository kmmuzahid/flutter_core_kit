/*
 * @Author: Km Muzahid
 * @Date: 2026-01-06 10:26:29
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: .fromSeed(
          seedColor: Colors.lightBlue,
          primary: Colors.lightBlue,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
      ),
      home: Scaffold(
        body: CoreKit.init(
          back: () {
            navigatorKey.currentState?.pop();
          },
          imageBaseUrl: 'https://',
          navigatorKey: navigatorKey,
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
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Test()),
        ),
      ),
    );
  }
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                _buildItem('CommonButton', CommonButton(onTap: () {}, titleText: 'CommonButton')),
                _buildItem(
                  "CommonRadioGroup",
                  CommonRadioGroup(
                    options: {
                      'Option 1': 'Option 1',
                      'Option 2': 'Option 2',
                      'Option 3': 'Option 3',
                    },
                    onChanged: (value) {},
                  ),
                ),
                _buildItem(
                  "CommonRadioFormField",
                  CommonRadioFormField(
                    options: {
                      'Option 1': 'Option 1',
                      'Option 2': 'Option 2',
                      'Option 3': 'Option 3',
                    },
                    onSaved: (value) {},
                  ),
                ),
                _buildItem(
                  "CommonSelectableButton",
                  CommonSelectableButton(
                    width: 130,
                    titles: ['Option 1', 'Option 2', 'Option 3'],
                    onSaved: (value) {},
                  ),
                ),
                _buildItem(
                  "StateDropdown",
                  CommonStateDropdown(countryName: 'Bangladesh', onChanged: (value) {}),
                ),
                _buildItem(
                  "City dropdown",
                  CommonCityDropDown(
                    selectedCountry: 'Bangladesh',
                    selectedState: 'Dhaka Division',
                    onChange: (value) {},
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: .bottomCenter,
          child: CommonDraggableBottomSheet(
            minChildSize: 0.13,
            maxChildSize: .33,
            collapsedContent: Column(children: [Text('expanded 1'), Text('expanded 3')]),
            expandedContent: Column(
              children: [Text('expanded 1'), Text('expanded 2'), Text('expanded 3')],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String name, Widget child) {
    return Column(
      children: [
        10.height,
        CommonText(text: '$name:').start,
        child.center,
      ],
    );
  }
}
