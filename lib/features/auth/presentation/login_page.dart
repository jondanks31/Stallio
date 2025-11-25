import 'package:flutter/material.dart';

import '../../auth/data/auth_repository.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      await _authRepository.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorText = 'Failed to sign in. Please check your details.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withOpacity(0.2)
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
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
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
            const SizedBox(height: 12),
            if (_errorText != null) ...[
              Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
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
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SignupPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
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
                        const Color(0xFFEDEDED).withOpacity(0.0),
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
                        const Color(0xFFFEF08A).withOpacity(0.8),
                        const Color(0xFFFEFBEB).withOpacity(0.8),
                        const Color(0xFFEDEDED).withOpacity(0.0),
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
