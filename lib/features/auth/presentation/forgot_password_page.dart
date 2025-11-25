import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/ui/snackbar_service.dart';
import '../data/auth_repository.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.onNavigateToLogin});

  /// Callback to navigate to login page (used by AuthGate).
  final VoidCallback? onNavigateToLogin;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For web, redirect back to the current origin so the app can handle
      // the password recovery token in the URL hash.
      String? redirectUrl;
      if (kIsWeb) {
        final uri = Uri.base;
        redirectUrl =
            '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      }

      await _authRepository.sendPasswordResetEmail(
        email: _emailController.text.trim(),
        redirectTo: redirectUrl,
      );
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on SocketException {
      if (mounted) {
        SnackbarService.showError(context, 'No internet connection.');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to send reset email. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    if (widget.onNavigateToLogin != null) {
      widget.onNavigateToLogin!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
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

    Widget buildEmailSentContent() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 24),
          Text(
            'Check your email',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "We've sent a password reset link to:",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Click the link in the email to reset your password. '
            "If you don't see it, check your spam folder.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _navigateToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to login',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _emailSent = false),
            child: const Text('Try a different email'),
          ),
        ],
      );
    }

    Widget buildFormContent() {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset password',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your email and we'll send you a link to reset your password.",
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
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD66B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Send reset link',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Remember your password?',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildContent() {
      return _emailSent ? buildEmailSentContent() : buildFormContent();
    }

    Widget buildDesktopLayout() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Form
            Expanded(
              flex: 5,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: buildContent(),
                ),
              ),
            ),
            const SizedBox(width: 32),
            // Right: Image placeholder
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(color: const Color(0xFF1C1C1E)),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildMobileLayout() {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: buildContent(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base background
          Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEDEDED),
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
