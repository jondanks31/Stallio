import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/hover_widgets.dart';
import '../../../settings/data/settings_repository.dart';

/// Card widget displaying an extra service in a grid.
class ExtraCard extends StatelessWidget {
  const ExtraCard({
    super.key,
    required this.extra,
    required this.onEdit,
    required this.onDelete,
  });

  final Extra extra;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _getIcon() {
    switch (extra.name.toLowerCase()) {
      case 'arena':
        return Icons.sports_handball;
      case 'rug change':
        return Icons.checkroom;
      case 'feed':
        return Icons.restaurant;
      case 'turnout':
        return Icons.wb_sunny_outlined;
      case 'grooming':
        return Icons.brush;
      case 'exercise':
        return Icons.directions_run;
      case 'medication admin':
        return Icons.medication;
      case 'hold for farrier':
      case 'hold for vet':
        return Icons.medical_services_outlined;
      default:
        return Icons.add_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWeb = MediaQuery.of(context).size.width > 600;

    return HoverCard(
      onTap: isWeb ? null : onEdit,
      color: isDark ? BrandColors.cardBgDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row: icon and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BrandColors.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getIcon(), size: 18, color: BrandColors.yellow),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWeb)
                      HoverIconButton(icon: Icons.edit_outlined, onTap: onEdit),
                    if (isWeb) const SizedBox(width: 4),
                    HoverIconButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              extra.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '£${extra.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              extra.unit,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            const Spacer(),
            if (extra.isRecurring)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recurring',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              )
            else
              Text(
                'One-time',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }
}
