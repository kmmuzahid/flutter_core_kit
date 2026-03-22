/// Internal library exports - for use within core_kit package only.
/// Do not import this in external code.
library core_kit_internal;

// Re-export core_kit public API
export 'core_kit.dart';

// Internal-only exports
export 'initializer.dart' show coreKitInstanceSingleton, coreKitInstance;
