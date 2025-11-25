import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/ui/snackbar_service.dart';
import '../data/auth_repository.dart';

/// Page displayed when user clicks the password reset link from their email.
/// Allows them to enter and confirm a new password.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.onPasswordReset});

  /// Called after password is successfully reset to notify parent widget.
  final VoidCallback? onPasswordReset;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authRepository.updatePassword(
        newPassword: _passwordController.text,
      );

      // Sign out so user can log in fresh with new password
      await _authRepository.signOut();

      if (mounted) {
        SnackbarService.showSuccess(context, 'Password updated successfully!');
        // Let AuthGate handle showing login page - don't navigate away
        widget.onPasswordReset?.call();
      }
    } on AuthException catch (e) {
      if (mounted) {
        SnackbarService.showError(context, _mapAuthError(e.message));
      }
    } on SocketException {
      if (mounted) {
        SnackbarService.showError(context, 'No internet connection.');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to update password. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Password should be')) {
      return 'Password must be at least 6 characters.';
    }
    if (message.contains('same password')) {
      return 'New password must be different from your current password.';
    }
    return message;
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
              'Set new password',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your new password below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New password',
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
                  return 'Enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm password',
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
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
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
                        'Update password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildDesktopLayout() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: buildFormContent(),
                ),
              ),
            ),
            const SizedBox(width: 32),
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
            child: buildFormContent(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEDEDED),
          ),
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
          isDesktop ? buildDesktopLayout() : buildMobileLayout(),
        ],
      ),
    );
  }
}
