// This should trigger a lint error because we're importing from outside the allowed depth
import 'package:core_kit/test/protected_test.dart';

void main() {
  // This should show a lint error - accessing protected class from too far away
  final protected = TestProtectedClass();
  protected.doSomething();
  
  // This should also show a lint error
  final another = AnotherProtectedClass();
  another.doSomethingElse();
}
