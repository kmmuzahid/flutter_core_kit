// test/initializer_singleton_test.dart
//
// Targeted tests for the CoreKitInstanceSingleton rename.
// Change: `coreKitInstanceSingleton` → `CoreKitInstanceSingleton`
//         (lib/initializer.dart:73)
//
// Verifies:
//   - The class is accessible by the new UpperCamelCase name
//   - The singleton contract is intact (same instance always returned)
//   - The `coreKitInstance` getter returns the same object as `.instance`
//   - The type identity is correct

import 'package:core_kit/initializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreKitInstanceSingleton — rename from coreKitInstanceSingleton', () {
    // CS-01
    // The new UpperCamelCase name must compile and be accessible.
    // Simply referencing the class proves the rename is complete.
    test('CS-01: CoreKitInstanceSingleton is accessible by new name', () {
      final instance = CoreKitInstanceSingleton.instance;
      expect(instance, isNotNull);
      expect(instance, isA<CoreKitInstanceSingleton>());
    });

    // CS-02
    // Singleton contract: two calls to `.instance` must return the
    // exact same object (identical), not just equal.
    test('CS-02: .instance always returns the same object (singleton identity)', () {
      final a = CoreKitInstanceSingleton.instance;
      final b = CoreKitInstanceSingleton.instance;
      expect(identical(a, b), isTrue);
    });

    // CS-03
    // The `coreKitInstance` top-level getter is defined as:
    //   CoreKitInstanceSingleton get coreKitInstance => CoreKitInstanceSingleton.instance;
    // It must return the same object as `.instance`.
    test('CS-03: coreKitInstance getter returns same object as .instance', () {
      final viaGetter = coreKitInstance;
      final viaDirect = CoreKitInstanceSingleton.instance;
      expect(identical(viaGetter, viaDirect), isTrue);
    });

    // CS-04
    // Multiple repeated accesses through both paths must all be identical,
    // confirming the singleton is not re-created between calls.
    test('CS-04: repeated access through getter and .instance are all identical', () {
      final instances = [
        coreKitInstance,
        CoreKitInstanceSingleton.instance,
        coreKitInstance,
        CoreKitInstanceSingleton.instance,
      ];
      final first = instances.first;
      for (final inst in instances) {
        expect(identical(inst, first), isTrue);
      }
    });

    // CS-05
    // Type check: the object returned is specifically a CoreKitInstanceSingleton,
    // not some other type — confirms the rename did not introduce a type mismatch.
    test('CS-05: runtime type is CoreKitInstanceSingleton', () {
      expect(
        CoreKitInstanceSingleton.instance.runtimeType,
        equals(CoreKitInstanceSingleton),
      );
    });
  });
}
