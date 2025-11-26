import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../dashboard/presentation/owner_dashboard_page.dart';
import '../../home/presentation/user_home_page.dart';
import '../../onboarding/presentation/onboarding_wizard.dart';
import 'forgot_password_page.dart';
import 'login_page.dart';
import 'reset_password_page.dart';
import 'signup_page.dart';

/// Enum representing the different auth pages.
enum AuthPage { login, signup, forgotPassword, resetPassword }

/// Represents the user's app state after authentication.
enum AppState { loading, onboarding, ownerDashboard, userHome }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSubscription;

  AuthPage _currentAuthPage = AuthPage.login;
  bool _isInitialized = false;
  Session? _currentSession;

  // Profile state
  AppState _appState = AppState.loading;
  String? _yardId;

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

        // Load profile when session changes
        if (session != null) {
          _loadProfile();
        } else {
          _appState = AppState.loading;
          _yardId = null;
        }
      }
    });

    // Load profile if already logged in
    if (_currentSession != null) {
      _loadProfile();
    }

    // Mark as initialized after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        setState(() => _isInitialized = true);
      }
    });
  }

  /// Loads the user's profile to determine routing.
  Future<void> _loadProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _yardId = response?['yard_id'] as String?;
        _appState = _determineAppState(response);
      });
    } catch (e) {
      // If profile doesn't exist yet, show onboarding
      if (mounted) {
        setState(() => _appState = AppState.onboarding);
      }
    }
  }

  /// Determines which app state to show based on profile.
  AppState _determineAppState(Map<String, dynamic>? profile) {
    if (profile == null) return AppState.onboarding;

    final onboardingCompleted =
        profile['onboarding_completed'] as bool? ?? false;
    if (!onboardingCompleted) return AppState.onboarding;

    final yardId = profile['yard_id'] as String?;
    final role = profile['role'] as String? ?? 'user';

    // If user has a yard, show appropriate dashboard
    if (yardId != null) {
      // Owner, manager, staff all go to the main dashboard
      if (role == 'owner' || role == 'manager' || role == 'staff') {
        return AppState.ownerDashboard;
      }
      // Regular users in a yard also go to dashboard (with limited features)
      return AppState.ownerDashboard;
    }

    // User without a yard goes to user home
    return AppState.userHome;
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
    // Show loading while initializing
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If not authenticated, show auth pages
    if (_currentSession == null) {
      return _buildAuthPage();
    }

    // If authenticated, route based on profile state
    switch (_appState) {
      case AppState.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AppState.onboarding:
        return OnboardingWizard(
          onComplete: _loadProfile, // Reload profile after onboarding
        );

      case AppState.ownerDashboard:
        return OwnerDashboardPage(yardId: _yardId!);

      case AppState.userHome:
        return const UserHomePage();
    }
  }

  Widget _buildAuthPage() {
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
