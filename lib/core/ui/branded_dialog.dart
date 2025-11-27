import 'package:flutter/material.dart';

/// Brand colors used across the app.
class BrandColors {
  static const yellow = Color(0xFFFFD66B);
  static const charcoal = Color(0xFF1E1E1E);
  static const dialogBgDark = Color(0xFF1E293B);
  static const dialogBgLight = Color(0xFFF8F8F8);
  static const cardBgDark = Color(0xFF2A2A2A);
}

/// Branded input decoration for form fields.
InputDecoration brandedInputDecoration({
  required BuildContext context,
  required String label,
  String? hint,
  String? prefix,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefix,
    filled: true,
    fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

/// Branded dropdown decoration.
InputDecoration brandedDropdownDecoration({
  required BuildContext context,
  required String label,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

/// Standard cancel button for dialogs.
class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context, null),
      child: const Text('Cancel'),
    );
  }
}

/// Primary action button for dialogs.
class DialogPrimaryButton extends StatelessWidget {
  const DialogPrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed ?? () => Navigator.pop(context, true),
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.yellow,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

/// Delete button for dialogs.
class DialogDeleteButton extends StatelessWidget {
  const DialogDeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.pop(context, true),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Delete'),
    );
  }
}

/// Shows a branded confirmation dialog.
Future<bool> showDeleteConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                ctx,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const DialogCancelButton(),
                const SizedBox(width: 12),
                const DialogDeleteButton(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
