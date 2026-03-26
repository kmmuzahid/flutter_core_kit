import 'package:core_kit/annotations/protected.dart';

// This should be protected
@Protected(depth: 1)
class TestProtectedClass {
  void doSomething() => print('Protected class');
}

// This should trigger a lint error when imported from outside allowed depth
@Protected(depth: 1)
class AnotherProtectedClass {
  void doSomethingElse() => print('Another protected class');
}
