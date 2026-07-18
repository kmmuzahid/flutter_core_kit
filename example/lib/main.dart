/// CoreKit example app.
///
/// This file demonstrates the main features of the core_kit package
/// as documented in the README, including:
///   - [CoreKit] bootstrap with [CoreKitConfig]
///   - [CkButton], [CkText], [CkTextField], [CkImage]
///   - [CkTransport] for HTTP requests
///   - [CkSnackBar] overlays
///   - [CkStorage] secure key-value storage
///   - [CkListView] with pagination
///   - Responsive layout extensions (.w, .h, .sp)

// ignore_for_file: avoid_print

import 'package:core_kit/core_kit.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:flutter/material.dart';

// ── App entry point ────────────────────────────────────────────────────────

void main() => runApp(const CoreKitExampleApp());

// ── Config ─────────────────────────────────────────────────────────────────

/// Minimal [CoreKitConfig] implementation using JSONPlaceholder as demo API.
class AppConfig extends CoreKitConfig with CoreKitConfigDefaults {
  @override
  String get imageBaseUrl => 'https://picsum.photos/';

  @override
  CkTransportConfig get ckTransportConfig => CkTransportConfig(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        refreshTokenEndpoint: '/auth/refresh',
        enableDebugLogs: true,
      );

  @override
  Widget? get preInitChild => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

  // Disable the 3 s splash delay in this demo so we reach the UI quickly.
  @override
  int get splashDelayMs => 0;
}

// ── Root widget ────────────────────────────────────────────────────────────

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
      home: const _HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ── Home page ──────────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CoreKit Demo'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(
            context,
            icon: Icons.text_fields,
            title: 'CkText & CkButton',
            page: const _TextButtonPage(),
          ),
          _tile(
            context,
            icon: Icons.text_format,
            title: 'CkTextField & Form',
            page: const _FormPage(),
          ),
          _tile(
            context,
            icon: Icons.image,
            title: 'CkImage',
            page: const _ImagePage(),
          ),
          _tile(
            context,
            icon: Icons.http,
            title: 'CkTransport (HTTP)',
            page: const _TransportPage(),
          ),
          _tile(
            context,
            icon: Icons.storage,
            title: 'CkStorage',
            page: const _StoragePage(),
          ),
          _tile(
            context,
            icon: Icons.list,
            title: 'CkListView (pagination)',
            page: const _ListPage(),
          ),
          _tile(
            context,
            icon: Icons.straighten,
            title: 'Responsive layout (.w / .h / .sp)',
            page: const _ResponsivePage(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}

// ── CkText & CkButton ──────────────────────────────────────────────────────

class _TextButtonPage extends StatelessWidget {
  const _TextButtonPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CkText & CkButton'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CkText(text: 'Body text using CkText'),
            const SizedBox(height: 8),
            const CkText(
              text: 'Bold headline',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            const CkText(
              text: 'Coloured text',
              fontSize: 16,
              textColor: Color(0xFF6750A4),
            ),
            const SizedBox(height: 20),
            CkButton(
              titleText: 'Success snackbar',
              onTap: () => CkSnackBar(
                'CoreKit is ready! ✅',
                type: CkSnackBarType.success,
              ),
            ),
            const SizedBox(height: 12),
            CkButton(
              titleText: 'Error snackbar',
              buttonColor: Colors.red,
              onTap: () => CkSnackBar(
                'Something went wrong ❌',
                type: CkSnackBarType.error,
              ),
            ),
            const SizedBox(height: 12),
            CkButton(
              titleText: 'Loading state',
              isLoading: true,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            CkButton(
              titleText: 'Gradient button',
              gradient: const LinearGradient(
                colors: [Color(0xFF6750A4), Color(0xFF03DAC6)],
              ),
              onTap: () => CkSnackBar('Gradient!', type: CkSnackBarType.info),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CkTextField & Form ─────────────────────────────────────────────────────

class _FormPage extends StatefulWidget {
  const _FormPage();

  @override
  State<_FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<_FormPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  // ignore: unused_field
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CkTextField & Form'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CkTextField(
                validationType: CkValidationType.validateEmail,
                labelText: 'Email',
                hintText: 'user@example.com',
                onSaved: (v, _) => _email = v,
              ),
              const SizedBox(height: 12),
              CkTextField(
                validationType: CkValidationType.validatePassword,
                labelText: 'Password',
                hintText: '••••••••',
                onSaved: (v, _) => _password = v,
              ),
              const SizedBox(height: 20),
              CkButton(
                titleText: 'Submit',
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    CkSnackBar(
                      'Valid — email: $_email',
                      type: CkSnackBarType.success,
                    );
                  } else {
                    CkSnackBar(
                      'Fix the errors above',
                      type: CkSnackBarType.error,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CkImage ────────────────────────────────────────────────────────────────

class _ImagePage extends StatelessWidget {
  const _ImagePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CkImage'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CkText(text: 'Network URL (absolute)', textAlign: TextAlign.left),
          const SizedBox(height: 8),
          const CkImage(
            src: 'https://picsum.photos/seed/a/600/300',
            width: double.infinity,
            height: 160,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),
          const CkText(text: 'Grayscale', textAlign: TextAlign.left),
          const SizedBox(height: 8),
          const CkImage(
            src: 'https://picsum.photos/seed/b/600/300',
            width: double.infinity,
            height: 160,
            borderRadius: 12,
            enableGrayscale: true,
          ),
          const SizedBox(height: 16),
          const CkText(text: 'Fixed size with border', textAlign: TextAlign.left),
          const SizedBox(height: 8),
          Center(
            child: CkImage(
              src: 'https://picsum.photos/seed/c/200/200',
              size: 120,
              borderRadius: 60,
              borderWidth: 3,
              borderColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CkTransport ────────────────────────────────────────────────────────────

class _TransportPage extends StatefulWidget {
  const _TransportPage();

  @override
  State<_TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<_TransportPage> {
  CkResponse<Map<String, dynamic>?>? _response;
  bool _loading = false;

  Future<void> _fetchGet() async {
    setState(() {
      _loading = true;
      _response = null;
    });

    // GET request — mirrors README section "Transport (HTTP)"
    final res = await CkTransport.request<Map<String, dynamic>>(
      input: RequestInput(
        endpoint: '/posts/1',
        method: RequestMethod.GET,
      ),
      responseBuilder: (data) => data is Map<String, dynamic> ? data : null,
    );

    setState(() {
      _loading = false;
      _response = res;
    });
  }

  Future<void> _fetchPost() async {
    setState(() {
      _loading = true;
      _response = null;
    });

    // POST with JSON body — mirrors README "POST with JSON body"
    final res = await CkTransport.request<Map<String, dynamic>>(
      input: RequestInput(
        endpoint: '/posts',
        method: RequestMethod.POST,
        jsonBody: {'title': 'CoreKit demo', 'body': 'Hello!', 'userId': 1},
      ),
      responseBuilder: (data) => data is Map<String, dynamic> ? data : null,
    );

    setState(() {
      _loading = false;
      _response = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = _response;
    return Scaffold(
      appBar: const CkAppBar(title: 'CkTransport (HTTP)'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CkButton(
              titleText: 'GET  /posts/1',
              isLoading: _loading,
              onTap: _fetchGet,
            ),
            const SizedBox(height: 12),
            CkButton(
              titleText: 'POST /posts',
              isLoading: _loading,
              buttonColor: const Color(0xFF018786),
              onTap: _fetchPost,
            ),
            if (res != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: res.isSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: res.isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CkText(
                      text: 'Status ${res.statusCode} · '
                          '${res.isSuccess ? "✅ isSuccess" : "❌ failed"}',
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 6),
                    CkText(
                      text: res.data?.toString() ?? res.message ?? '—',
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── CkStorage ──────────────────────────────────────────────────────────────

class _StoragePage extends StatefulWidget {
  const _StoragePage();

  @override
  State<_StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<_StoragePage> {
  String? _readValue;

  Future<void> _write() async {
    await CkStorage.write('demo_key', 'hello_core_kit_${DateTime.now().second}');
    CkSnackBar('Written ✅', type: CkSnackBarType.success);
  }

  Future<void> _read() async {
    final v = await CkStorage.read('demo_key');
    setState(() => _readValue = v);
    CkSnackBar('Read: $v', type: CkSnackBarType.info);
  }

  Future<void> _delete() async {
    await CkStorage.delete('demo_key');
    setState(() => _readValue = null);
    CkSnackBar('Deleted 🗑️', type: CkSnackBarType.warning);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CkStorage'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CkButton(titleText: 'write("demo_key", …)', onTap: _write),
            const SizedBox(height: 12),
            CkButton(titleText: 'read("demo_key")', onTap: _read),
            const SizedBox(height: 12),
            CkButton(
              titleText: 'delete("demo_key")',
              buttonColor: Colors.red,
              onTap: _delete,
            ),
            if (_readValue != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text('Stored value: $_readValue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── CkListView (pagination) ────────────────────────────────────────────────

class _ListPage extends StatefulWidget {
  const _ListPage();

  @override
  State<_ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<_ListPage> {
  final _items = <Map<String, dynamic>>[];
  bool _loading = false;
  bool _loadDone = false;

  Future<void> _fetch(int page) async {
    setState(() => _loading = true);

    // JSONPlaceholder returns 100 posts; we fake pagination with _start/_limit.
    final res = await CkTransport.request<List<Map<String, dynamic>>>(
      input: RequestInput(
        endpoint: '/posts',
        method: RequestMethod.GET,
        queryParams: {'_start': (page - 1) * 10, '_limit': 10},
        requiresToken: false,
      ),
      responseBuilder: (data) => data is List
          ? data.whereType<Map<String, dynamic>>().toList()
          : null,
    );

    if (res.isSuccess && res.data != null) {
      setState(() {
        if (page == 1) _items.clear();
        _items.addAll(res.data!);
        _loadDone = res.data!.length < 10;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      CkSnackBar(res.message ?? 'Request failed', type: CkSnackBarType.error);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetch(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'CkListView (pagination)'),
      body: CkListView(
        itemCount: _items.length,
        isLoading: _loading,
        isLoadDone: _loadDone,
        onRefresh: () => _fetch(1),
        onLoadMore: (page) => _fetch(page),
        emptyWidget: const Center(child: Text('No posts')),
        itemBuilder: (context, index) {
          final post = _items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${post['id']}')),
              title: Text(
                post['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                post['body'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Responsive layout ──────────────────────────────────────────────────────

class _ResponsivePage extends StatelessWidget {
  const _ResponsivePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CkAppBar(title: 'Responsive layout'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CkText(
              text: 'Widths / heights / font-sizes below scale automatically '
                  'relative to the design size (428 × 926).',
              textColor: Colors.grey,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200.w,
              height: 60.h,
              color: const Color(0xFF6750A4),
              alignment: Alignment.center,
              child: const CkText(
                text: '200.w × 60.h',
                textColor: Colors.white,
                fontSize: 14,
              ),
            ),
            20.height, // SizedBox(height: 20.h)
            Container(
              width: 300.w,
              height: 60.h,
              color: const Color(0xFF03DAC6),
              alignment: Alignment.center,
              child: const CkText(
                text: '300.w × 60.h',
                fontSize: 16,
              ),
            ),
            20.height,
            const CkText(
              text: 'Font at 24.sp',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.left,
            ),
            12.height,
            const CkText(
              text: 'Font at 14.sp',
              fontSize: 14,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
