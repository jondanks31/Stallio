import 'package:flutter/material.dart';

/// Centralized service for displaying snackbar messages.
/// Provides consistent styling for success, error, warning, and info messages.
class SnackbarService {
  const SnackbarService._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, _SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, _SnackbarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, _SnackbarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, _SnackbarType.info);
  }

  static void _show(BuildContext context, String message, _SnackbarType type) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final colors = _getColors(type);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    // Compact width on desktop, near full-width on mobile
    final snackbarWidth = isDesktop ? 300.0 : screenWidth - 32;

    // Left-align on desktop by using asymmetric margins
    final rightMargin = isDesktop ? screenWidth - snackbarWidth - 24 : 16.0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(colors.icon, color: colors.foreground, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: colors.foreground, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: colors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(bottom: 20, left: 24, right: rightMargin),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        duration: Duration(seconds: type == _SnackbarType.error ? 4 : 2),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static _SnackbarColors _getColors(_SnackbarType type) {
    switch (type) {
      case _SnackbarType.success:
        return _SnackbarColors(
          background: const Color(0xFF065F46),
          foreground: Colors.white,
          icon: Icons.check_circle_outline,
        );
      case _SnackbarType.error:
        return _SnackbarColors(
          background: const Color(0xFF991B1B),
          foreground: Colors.white,
          icon: Icons.error_outline,
        );
      case _SnackbarType.warning:
        return _SnackbarColors(
          background: const Color(0xFF92400E),
          foreground: Colors.white,
          icon: Icons.warning_amber_outlined,
        );
      case _SnackbarType.info:
        return _SnackbarColors(
          background: const Color(0xFF1E40AF),
          foreground: Colors.white,
          icon: Icons.info_outline,
        );
    }
  }
}

enum _SnackbarType { success, error, warning, info }

class _SnackbarColors {
  final Color background;
  final Color foreground;
  final IconData icon;

  const _SnackbarColors({
    required this.background,
    required this.foreground,
    required this.icon,
  });
}
