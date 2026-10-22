import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CkShare.resolveImageUrl Tests', () {
    test('returns full URL unchanged when starting with https://', () {
      const url = 'https://cdn.example.com/images/pic.jpg';
      expect(CkShare.resolveImageUrl(url), url);
    });

    test('returns full URL unchanged when starting with http://', () {
      const url = 'http://cdn.example.com/images/pic.jpg';
      expect(CkShare.resolveImageUrl(url), url);
    });

    test('handles case-insensitive scheme (HTTPS://)', () {
      const url = 'HTTPS://cdn.example.com/images/pic.jpg';
      expect(CkShare.resolveImageUrl(url), url);
    });

    test('prepends https: to protocol-relative URLs starting with //', () {
      expect(
        CkShare.resolveImageUrl('//cdn.example.com/images/pic.jpg'),
        'https://cdn.example.com/images/pic.jpg',
      );
    });

    test('prepends https:// to domain-only URLs without scheme', () {
      expect(
        CkShare.resolveImageUrl('cdn.example.com/images/pic.jpg'),
        'https://cdn.example.com/images/pic.jpg',
      );
      expect(
        CkShare.resolveImageUrl('res.cloudinary.com/demo/image/sample.jpg'),
        'https://res.cloudinary.com/demo/image/sample.jpg',
      );
      expect(
        CkShare.resolveImageUrl('images.unsplash.com/photo-12345'),
        'https://images.unsplash.com/photo-12345',
      );
      expect(
        CkShare.resolveImageUrl('assets.my-site.org:8080/img.png'),
        'https://assets.my-site.org:8080/img.png',
      );
    });

    test('trims surrounding whitespace properly', () {
      expect(
        CkShare.resolveImageUrl('   https://cdn.example.com/pic.jpg  '),
        'https://cdn.example.com/pic.jpg',
      );
      expect(
        CkShare.resolveImageUrl('   cdn.example.com/pic.jpg  '),
        'https://cdn.example.com/pic.jpg',
      );
    });

    test('resolves relative paths with imageBaseUrl without double slashes', () {
      coreKitInstance.imageBaseUrl = 'https://api.example.com/';

      expect(
        CkShare.resolveImageUrl('/uploads/avatar.jpg'),
        'https://api.example.com/uploads/avatar.jpg',
      );
      expect(
        CkShare.resolveImageUrl('uploads/avatar.jpg'),
        'https://api.example.com/uploads/avatar.jpg',
      );
      expect(
        CkShare.resolveImageUrl('avatar.jpg'),
        'https://api.example.com/avatar.jpg',
      );
    });

    test('resolves relative paths when imageBaseUrl has no trailing slash', () {
      coreKitInstance.imageBaseUrl = 'https://api.example.com';

      expect(
        CkShare.resolveImageUrl('/uploads/avatar.jpg'),
        'https://api.example.com/uploads/avatar.jpg',
      );
      expect(
        CkShare.resolveImageUrl('uploads/avatar.jpg'),
        'https://api.example.com/uploads/avatar.jpg',
      );
      expect(
        CkShare.resolveImageUrl('avatar.jpg'),
        'https://api.example.com/avatar.jpg',
      );
    });

    test('handles path containing version/numeric segments without mistaking as domain', () {
      coreKitInstance.imageBaseUrl = 'https://api.example.com';

      expect(
        CkShare.resolveImageUrl('v1.0/images/cat.jpg'),
        'https://api.example.com/v1.0/images/cat.jpg',
      );
      expect(
        CkShare.resolveImageUrl('/v2.1/avatar.png'),
        'https://api.example.com/v2.1/avatar.png',
      );
    });
  });

  group('CkShareButton Widget Tests', () {
    testWidgets('renders child widget correctly in direct child mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CkShareButton(
              title: 'Title',
              deepLinkUrl: 'https://example.com',
              imageUrl: 'https://cdn.example.com/pic.jpg',
              child: Icon(Icons.share, key: Key('share_icon')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('share_icon')), findsOneWidget);
    });

    testWidgets('builder mode provides share callback and isLoading state', (
      tester,
    ) async {
      bool? lastLoadingState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CkShareButton.builder(
              title: 'Title',
              deepLinkUrl: 'https://example.com',
              imageUrl: 'https://cdn.example.com/pic.jpg',
              builder: (context, share, isLoading) {
                lastLoadingState = isLoading;
                return ElevatedButton(
                  key: const Key('custom_share_btn'),
                  onPressed: share,
                  child: Text(isLoading ? 'Sharing...' : 'Share'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_share_btn')), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(lastLoadingState, false);
    });

    testWidgets('supports CkShare.button and CkShare.builder static shortcuts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CkShare.button(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  child: const Icon(Icons.share, key: Key('shortcut_icon')),
                ),
                CkShare.builder(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  builder: (context, share, isLoading) =>
                      const Text('Shortcut Builder', key: Key('shortcut_text')),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('shortcut_icon')), findsOneWidget);
      expect(find.byKey(const Key('shortcut_text')), findsOneWidget);
    });

    testWidgets('supports replace and overlay loader styles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CkShareButton(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  loaderStyle: CkShareLoaderStyle.replace,
                  child: Icon(Icons.share, key: Key('replace_icon')),
                ),
                CkShareButton(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  loaderStyle: CkShareLoaderStyle.overlay,
                  child: Icon(Icons.share, key: Key('overlay_icon')),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('replace_icon')), findsOneWidget);
      expect(find.byKey(const Key('overlay_icon')), findsOneWidget);
    });

    testWidgets('supports circular shape and custom borderRadius', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CkShareButton(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  shape: BoxShape.circle,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(Icons.share),
                  ),
                ),
                CkShareButton(
                  title: 'Title',
                  deepLinkUrl: 'https://example.com',
                  imageUrl: 'https://cdn.example.com/pic.jpg',
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Share Button'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Share Button'), findsOneWidget);
    });

    test('CkShare.listenDeepLink returns a cancellable subscription', () async {
      Uri? received;
      final sub = CkShare.listenDeepLink((uri) {
        received = uri;
      });

      expect(sub, isNotNull);
      expect(received, isNull);

      await sub.cancel();
    });
  });
}

