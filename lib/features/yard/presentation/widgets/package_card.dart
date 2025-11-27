import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../settings/data/settings_repository.dart';

/// Card widget displaying a livery package in a list.
class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  final LiveryPackage package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final includedCount = package.includedItems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BrandColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              size: 20,
              color: BrandColors.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '£${package.basePrice.toStringAsFixed(2)}/month • $includedCount included extra${includedCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            style: IconButton.styleFrom(foregroundColor: Colors.grey),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: Colors.red.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
