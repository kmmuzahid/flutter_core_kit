// test/auth/unit/behavior_stream_test.dart
import 'package:core_kit/auth/reactive/behavior_stream.dart';
import 'package:core_kit/auth/state/auth_loading_controller.dart';
// Imports needed for the inline test helpers:
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkBehaviorStream', () {
    test('initialValue is accessible synchronously via .value', () {
      final stream = CkBehaviorStream<int>(initialValue: 42);
      expect(stream.value, equals(42));
      stream.dispose();
    });

    test('new subscriber immediately receives current value via listen()', () {
      final stream = CkBehaviorStream<String>(initialValue: 'hello');
      final received = <String>[];

      final sub = stream.listen((v) => received.add(v));
      expect(received, equals(['hello'])); // immediate replay

      sub.cancel();
      stream.dispose();
    });

    test('add() updates value and emits to subscribers', () async {
      final stream = CkBehaviorStream<int>(initialValue: 0);
      final received = <int>[];

      final sub = stream.stream.listen((v) => received.add(v));
      stream.add(1);
      stream.add(2);
      stream.add(3);

      await Future.delayed(Duration.zero);
      expect(received, equals([1, 2, 3]));
      expect(stream.value, equals(3));

      sub.cancel();
      stream.dispose();
    });

    test('multiple subscribers each receive updates', () async {
      final stream = CkBehaviorStream<bool>(initialValue: false);
      final recv1 = <bool>[];
      final recv2 = <bool>[];

      final sub1 = stream.stream.listen((v) => recv1.add(v));
      final sub2 = stream.stream.listen((v) => recv2.add(v));

      stream.add(true);
      await Future.delayed(Duration.zero);

      expect(recv1, contains(true));
      expect(recv2, contains(true));

      sub1.cancel();
      sub2.cancel();
      stream.dispose();
    });

    test(
      'late subscriber gets current value immediately via listen()',
      () async {
        final stream = CkBehaviorStream<int>(initialValue: 0);
        stream.add(99);

        final received = <int>[];
        final sub = stream.listen((v) => received.add(v));
        // Should immediately get 99 (current value)
        expect(received, equals([99]));

        sub.cancel();
        stream.dispose();
      },
    );

    test('dispose() closes stream without error', () {
      final stream = CkBehaviorStream<int>(initialValue: 0);
      expect(() => stream.dispose(), returnsNormally);
    });
  });

  group('CkAuthStateController', () {
    test('initial status is unknown', () {
      final ctrl = _buildStateController();
      expect(ctrl.isChecking, isTrue);
      expect(ctrl.isAuthenticated, isFalse);
      ctrl.dispose();
    });

    test('setAuthenticated → isAuthenticated=true', () {
      final ctrl = _buildStateController();
      ctrl.setAuthenticated();
      expect(ctrl.isAuthenticated, isTrue);
      ctrl.dispose();
    });

    test('setUnauthenticated → isUnauthenticated=true', () {
      final ctrl = _buildStateController();
      ctrl.setUnauthenticated();
      expect(ctrl.isUnauthenticated, isTrue);
      ctrl.dispose();
    });
  });

  group('CkAuthLoadingController', () {
    test('initial loading state is false for all types', () {
      final ctrl = _buildLoadingController();
      for (final type in _loadingTypes) {
        expect(ctrl.isLoading(type), isFalse);
      }
      ctrl.dispose();
    });

    test('setLoading(true) sets loading to true for that type', () {
      final ctrl = _buildLoadingController();
      ctrl.setLoading(_loadingTypes.first, true);
      expect(ctrl.isLoading(_loadingTypes.first), isTrue);
      ctrl.dispose();
    });

    test('wrap() sets loading true, runs action, then sets false', () async {
      final ctrl = _buildLoadingController();
      final loadingStates = <bool>[];

      final stream = ctrl.streamOf(_loadingTypes.first);
      final sub = stream.stream.listen(loadingStates.add);

      await ctrl.wrap(_loadingTypes.first, () async {
        await Future.delayed(Duration.zero);
      });

      await Future.delayed(Duration.zero);
      // Should have seen true → false
      expect(loadingStates, contains(true));
      expect(loadingStates.last, isFalse);

      sub.cancel();
      ctrl.dispose();
    });
  });
}

CkAuthStateController _buildStateController() => CkAuthStateController();
CkAuthLoadingController _buildLoadingController() => CkAuthLoadingController();
const _loadingTypes = CkAuthLoadingType.values;
