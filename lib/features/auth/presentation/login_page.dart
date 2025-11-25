import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ui/snackbar_service.dart';
import '../data/auth_repository.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onNavigateToSignup,
    this.onNavigateToForgotPassword,
  });

  /// Callback to navigate to signup page (used by AuthGate).
  final VoidCallback? onNavigateToSignup;

  /// Callback to navigate to forgot password page (used by AuthGate).
  final VoidCallback? onNavigateToForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authRepository.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate listens to auth state changes and will show authenticated content
    } on AuthException catch (e) {
      if (mounted) {
        // Show resend option for unverified emails
        if (e.message.contains('Email not confirmed')) {
          _showResendVerificationDialog();
        } else {
          SnackbarService.showError(context, _mapAuthError(e.message));
        }
      }
    } on SocketException {
      if (mounted) {
        SnackbarService.showError(context, 'No internet connection.');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Shows dialog offering to resend verification email.
  void _showResendVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email not verified'),
        content: Text(
          'Your email (${_emailController.text.trim()}) has not been verified yet. '
          'Would you like us to resend the verification email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resendVerificationEmail();
            },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }

  /// Resends the verification email.
  Future<void> _resendVerificationEmail() async {
    try {
      await _authRepository.resendVerificationEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Verification email sent! Check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to send verification email. Please try again.',
        );
      }
    }
  }

  /// Maps Supabase auth error messages to user-friendly text.
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password.';
    }
    return message;
  }

  void _navigateToForgotPassword() {
    if (widget.onNavigateToForgotPassword != null) {
      widget.onNavigateToForgotPassword!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ForgotPasswordPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _navigateToSignup() {
    if (widget.onNavigateToSignup != null) {
      widget.onNavigateToSignup!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SignupPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final isDark = theme.brightness == Brightness.dark;

    Widget buildFormContent() {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'STALLIO',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome back',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to manage your yard, horses, and team.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _navigateToForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToSignup,
              child: const Text("Don't have an account? Create one"),
            ),
          ],
        ),
      );
    }

    Widget buildDesktopLayout() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 640),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 24,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: buildFormContent(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFF1C1C1E)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildMobileLayout() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: buildFormContent(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Base background color
          Container(
            color: isDark ? const Color(0xFF020617) : const Color(0xFFEDEDED),
          ),
          // Gradient 1: Bottom Left
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), Colors.transparent]
                    : [
                        const Color(0xFFFEF08A),
                        const Color(0xFFFEFBEB),
                        const Color(0xFFEDEDED).withValues(alpha: 0.0),
                      ],
                stops: const [0.0, 0.4, 1.0],
                center: Alignment.bottomLeft,
                radius: 1.8,
              ),
            ),
          ),
          // Gradient 2: Right Side Lower-Middle
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), Colors.transparent]
                    : [
                        const Color(0xFFFEF08A).withValues(alpha: 0.8),
                        const Color(0xFFFEFBEB).withValues(alpha: 0.8),
                        const Color(0xFFEDEDED).withValues(alpha: 0.0),
                      ],
                stops: const [0.0, 0.4, 1.0],
                center: const Alignment(1.2, 0.4),
                radius: 1.5,
              ),
            ),
          ),
          // Content
          isDesktop ? buildDesktopLayout() : buildMobileLayout(),
        ],
      ),
    );
  }
}
