import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import 'forgot_password_page.dart';
import 'login_page.dart';
import 'reset_password_page.dart';
import 'signup_page.dart';

/// Enum representing the different auth pages.
enum AuthPage { login, signup, forgotPassword, resetPassword }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.childWhenAuthenticated});

  final Widget childWhenAuthenticated;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSubscription;

  AuthPage _currentAuthPage = AuthPage.login;
  bool _isInitialized = false;
  Session? _currentSession;

  @override
  void initState() {
    super.initState();
    _client = SupabaseManager.client;
    _currentSession = _client.auth.currentSession;

    // Check URL for password recovery token on web (handles PKCE flow issue)
    _checkForPasswordRecovery();

    // Subscribe to auth state changes
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      // Handle password recovery event from email link
      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _currentAuthPage = AuthPage.resetPassword);
        return;
      }

      // Update session state for other events
      if (mounted) {
        setState(() {
          _currentSession = session;
          _isInitialized = true;
        });
      }
    });

    // Mark as initialized after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        setState(() => _isInitialized = true);
      }
    });
  }

  /// On web, check the URL hash for recovery type parameter.
  /// This handles cases where the passwordRecovery event doesn't fire
  /// (e.g., with PKCE flow).
  void _checkForPasswordRecovery() {
    if (!kIsWeb) return;

    try {
      final uri = Uri.base;
      final fragment = uri.fragment;

      // Parse the hash fragment as query parameters
      // Format: #access_token=...&type=recovery&...
      if (fragment.isNotEmpty) {
        final params = Uri.splitQueryString(fragment);
        final type = params['type'];

        if (type == 'recovery') {
          // Delay slightly to ensure Supabase has processed the token
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() => _currentAuthPage = AuthPage.resetPassword);
            }
          });
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Navigate to a different auth page.
  void _navigateToAuthPage(AuthPage page) {
    setState(() => _currentAuthPage = page);
  }

  /// Called after password reset to return to login.
  void _onPasswordReset() {
    setState(() {
      _currentAuthPage = AuthPage.login;
      _currentSession = null; // Force back to login
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing (optional, prevents flash)
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If authenticated, show the main app
    if (_currentSession != null) {
      return widget.childWhenAuthenticated;
    }

    // Show the appropriate auth page
    switch (_currentAuthPage) {
      case AuthPage.login:
        return LoginPage(
          onNavigateToSignup: () => _navigateToAuthPage(AuthPage.signup),
          onNavigateToForgotPassword: () =>
              _navigateToAuthPage(AuthPage.forgotPassword),
        );
      case AuthPage.signup:
        return SignupPage(
          onNavigateToLogin: () => _navigateToAuthPage(AuthPage.login),
        );
      case AuthPage.forgotPassword:
        return ForgotPasswordPage(
          onNavigateToLogin: () => _navigateToAuthPage(AuthPage.login),
        );
      case AuthPage.resetPassword:
        return ResetPasswordPage(onPasswordReset: _onPasswordReset);
    }
  }
}
