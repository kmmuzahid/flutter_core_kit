// ignore_for_file: avoid_print

import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';

// ── App Configuration ──────────────────────────────────────────────────────

/// Example app configuration extending [CoreKitConfig].
///
/// In a real app replace the baseUrl with your actual API endpoint.
class AppConfig extends CoreKitConfig with CoreKitConfigDefaults {
  @override
  String get imageBaseUrl => 'https://picsum.photos/';

  @override
  CkTransportConfig get ckTransportConfig => CkTransportConfig(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        refreshTokenEndpoint: '/auth/refresh',
        enableDebugLogs: true,
      );
}

// ── Entry Point ────────────────────────────────────────────────────────────

void main() => runApp(const CoreKitExampleApp());

class CoreKitExampleApp extends StatelessWidget {
  const CoreKitExampleApp({super.key});

  static final GlobalKey<NavigatorState> _nav = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return CoreKit(
      navigatorKey: _nav,
      config: AppConfig(),
      title: 'CoreKit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const _ExampleHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ── Home Screen ─────────────────────────────────────────────────────────────

class _ExampleHome extends StatefulWidget {
  const _ExampleHome();

  @override
  State<_ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<_ExampleHome> {
  final _formKey = GlobalKey<FormState>();
  CkResponse<dynamic>? _apiResponse;
  bool _loading = false;

  Future<void> _fetchPost() async {
    setState(() {
      _loading = true;
      _apiResponse = null;
    });

    // Demonstrates CkTransport.request
    final response = await CkTransport.request<Map<String, dynamic>>(
      input: RequestInput(
        endpoint: '/posts/1',
        method: RequestMethod.GET,
      ),
      responseBuilder: (data) => data is Map<String, dynamic> ? data : null,
    );

    setState(() {
      _loading = false;
      _apiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoreKit Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── CkText ──────────────────────────────────────────────────────
            const _SectionHeader('CkText'),
            const CkText('Body text using CkText widget'),
            const CkText(
              'Headline text',
              type: CkTextType.headlineMedium,
            ),
            const SizedBox(height: 24),

            // ── CkButton ────────────────────────────────────────────────────
            const _SectionHeader('CkButton'),
            CkButton(
              label: 'Fetch /posts/1 via CkTransport',
              isLoading: _loading,
              onPressed: _fetchPost,
            ),
            if (_apiResponse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _apiResponse!.isSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _apiResponse!.isSuccess
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${_apiResponse!.statusCode}  '
                      '${_apiResponse!.isSuccess ? "✅ Success" : "❌ Failed"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _apiResponse!.data?.toString() ?? '—',
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── CkTextField ─────────────────────────────────────────────────
            const _SectionHeader('CkTextField (Form)'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CkTextField(
                    validationType: CkValidationType.validateEmail,
                    labelText: 'Email',
                    hintText: 'user@example.com',
                  ),
                  const SizedBox(height: 12),
                  CkTextField(
                    validationType: CkValidationType.validatePassword,
                    labelText: 'Password',
                  ),
                  const SizedBox(height: 12),
                  CkButton(
                    label: 'Validate form',
                    onPressed: () {
                      final valid = _formKey.currentState?.validate() ?? false;
                      CkSnackbar.show(
                        context,
                        message: valid ? 'Form is valid ✅' : 'Fix errors ❌',
                        isError: !valid,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── CkImage ─────────────────────────────────────────────────────
            const _SectionHeader('CkImage'),
            CkImage(
              imageUrl: '200/300',
              width: double.infinity,
              height: 180,
              borderRadius: 12,
            ),
            const SizedBox(height: 24),

            // ── CkStorage ───────────────────────────────────────────────────
            const _SectionHeader('CkStorage'),
            CkButton(
              label: 'Write & read a key',
              onPressed: () async {
                await CkStorage.write('demo_key', 'hello_core_kit');
                final value = await CkStorage.read('demo_key');
                if (context.mounted) {
                  CkSnackbar.show(context, message: 'Read: $value');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
