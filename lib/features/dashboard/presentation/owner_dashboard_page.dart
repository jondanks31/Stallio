import 'package:flutter/material.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../auth/data/auth_repository.dart';

/// Owner Dashboard - the main landing page after login for yard owners.
class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  final _authRepository = AuthRepository();
  bool _isLoggingOut = false;

  Future<void> _signOut() async {
    setState(() => _isLoggingOut = true);

    try {
      await _authRepository.signOut();
      // AuthGate will automatically show login page when session is cleared
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to sign out. Please try again.',
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logout button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STALLIO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoggingOut ? null : _signOut,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout, size: 18),
                      label: const Text('Sign out'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Page title
                Text(
                  'Owner Dashboard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Your yard overview will appear here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                // Placeholder content
                const Expanded(
                  child: Center(
                    child: Text(
                      'Dashboard content coming soon...',
                      style: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
