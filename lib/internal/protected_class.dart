import 'package:core_kit/annotations/protected.dart';

@Protected(depth: 1)
class InternalProtectedClass {
  void doSomething() => print('This should only be accessible within the same folder');
}
