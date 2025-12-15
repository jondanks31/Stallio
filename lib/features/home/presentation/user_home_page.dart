import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/deep_link_service.dart';
import '../../../core/ui/branded_dialog.dart';
import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../people/data/people_repository.dart';

/// Home page for users who are not part of a yard.
/// Shows options to join a yard, manage profile, and manage horses.
class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _authRepository = AuthRepository();
  final _peopleRepository = PeopleRepository();
  final _deepLinkService = DeepLinkService();
  final _inviteCodeController = TextEditingController();
  StreamSubscription<String>? _inviteTokenSubscription;
  bool _isLoggingOut = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _checkPendingInviteToken();
    _listenForInviteTokens();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _inviteTokenSubscription?.cancel();
    super.dispose();
  }

  /// Check if there's a pending invite token from app launch
  void _checkPendingInviteToken() {
    final token = _deepLinkService.pendingInviteToken;
    if (token != null) {
      _deepLinkService.clearPendingInviteToken();
      // Delay to ensure widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInviteToken(token);
      });
    }
  }

  /// Listen for invite tokens while app is running
  void _listenForInviteTokens() {
    _inviteTokenSubscription = _deepLinkService.inviteTokenStream.listen(
      _handleInviteToken,
    );
  }

  /// Handle an invite token from deep link
  Future<void> _handleInviteToken(String token) async {
    if (_isJoining) return;

    setState(() => _isJoining = true);

    try {
      await _peopleRepository.acceptInviteByToken(token);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Welcome! You have joined the yard.',
        );
        // Auth state listener will handle navigation
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
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
    _inviteCodeController.clear();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark ? BrandColors.dialogBgDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: BrandColors.yellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.group_add,
                            color: BrandColors.yellow,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Join a Yard',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Enter your invite code',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isJoining
                              ? null
                              : () => Navigator.pop(dialogContext),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Info text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Check your email for an invite code from your yard owner.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Code input
                    TextField(
                      controller: _inviteCodeController,
                      enabled: !_isJoining,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ABC123',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                    ),
                    const SizedBox(height: 24),
                    // Join button
                    FilledButton(
                      onPressed: _isJoining
                          ? null
                          : () async {
                              // Remove all whitespace and get clean code
                              final code = _inviteCodeController.text
                                  .replaceAll(RegExp(r'\s+'), '')
                                  .toUpperCase();
                              debugPrint(
                                'Submitting invite code: "$code" (length: ${code.length})',
                              );

                              if (code.length != 6) {
                                SnackbarService.showError(
                                  context,
                                  'Please enter a 6-character invite code',
                                );
                                return;
                              }

                              setDialogState(() => _isJoining = true);
                              setState(() => _isJoining = true);

                              try {
                                await _peopleRepository.acceptInviteByCode(
                                  code,
                                );
                                if (!context.mounted) return;
                                Navigator.pop(dialogContext);
                                SnackbarService.showSuccess(
                                  context,
                                  'Welcome! You have joined the yard.',
                                );
                                // The auth state listener will handle navigation
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarService.showError(
                                  context,
                                  e.toString().replaceAll('Exception: ', ''),
                                );
                              } finally {
                                if (mounted) {
                                  setDialogState(() => _isJoining = false);
                                  setState(() => _isJoining = false);
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandColors.yellow,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black54,
                              ),
                            )
                          : const Text(
                              'Join Yard',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
