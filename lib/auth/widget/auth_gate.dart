import 'dart:async';
import 'package:flutter/material.dart';
import 'package:core_kit/auth/auth_service.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';

/// Widget that auto-switches UI based on auth stream.
/// Works with any routing approach.
class AuthGate extends StatefulWidget {
  final Widget authenticatedChild;
  final Widget unauthenticatedChild;
  final Widget? loadingChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
    this.loadingChild,
  });
  
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthStatus>? _subscription;
  AuthStatus _status = AuthStatus.unknown;
  
  @override
  void initState() {
    super.initState();
    if (AuthService.isInitialized) {
      _subscription = AuthService.instance.authState.status.listen((status) {
        if (mounted) setState(() => _status = status);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!AuthService.isInitialized) {
      return widget.unauthenticatedChild;
    }

    switch (_status) {
      case AuthStatus.unknown:
        return widget.loadingChild ?? 
          const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return widget.authenticatedChild;
      case AuthStatus.unauthenticated:
        return widget.unauthenticatedChild;
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
