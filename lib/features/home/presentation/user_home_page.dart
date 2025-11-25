import 'package:flutter/material.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../auth/data/auth_repository.dart';

/// Home page for users who are not part of a yard.
/// Shows options to join a yard, manage profile, and manage horses.
class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _authRepository = AuthRepository();
  final _inviteCodeController = TextEditingController();
  bool _isLoggingOut = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    setState(() => _isLoggingOut = true);

    try {
      await _authRepository.signOut();
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to sign out.');
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _showJoinYardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a yard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the invite code from your yard owner:'),
            const SizedBox(height: 16),
            TextField(
              controller: _inviteCodeController,
              decoration: const InputDecoration(
                labelText: 'Invite code',
                hintText: 'e.g. ABC123',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement yard join request
              SnackbarService.showInfo(
                context,
                'Yard join feature coming soon!',
              );
            },
            child: const Text('Request access'),
          ),
        ],
      ),
    );
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
                // Header
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
                // Welcome
                Text(
                  'Welcome!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're not part of a yard yet. Join one to access all features.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Join yard card
                _buildActionCard(
                  icon: Icons.group_add_outlined,
                  title: 'Join a yard',
                  subtitle: 'Enter an invite code from your yard owner',
                  onTap: _showJoinYardDialog,
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                // My horses card
                _buildActionCard(
                  icon: Icons.pets_outlined,
                  title: 'My horses',
                  subtitle: 'Add and manage your horses',
                  onTap: () {
                    // TODO: Navigate to horses page
                    SnackbarService.showInfo(
                      context,
                      'Horses feature coming soon!',
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Profile card
                _buildActionCard(
                  icon: Icons.person_outline,
                  title: 'My profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    // TODO: Navigate to profile page
                    SnackbarService.showInfo(
                      context,
                      'Profile feature coming soon!',
                    );
                  },
                ),
                const Spacer(),
                // Info text
                Center(
                  child: Text(
                    'Waiting for a yard invite? Check your email.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFFFD66B).withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? Border.all(color: const Color(0xFFFFD66B), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? const Color(0xFFFFD66B)
                    : (isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isPrimary
                    ? Colors.black87
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
