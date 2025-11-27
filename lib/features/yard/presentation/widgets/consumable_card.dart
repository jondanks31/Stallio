import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/hover_widgets.dart';
import '../../../settings/data/settings_repository.dart';

/// Card widget displaying a consumable item in a grid.
class ConsumableCard extends StatelessWidget {
  const ConsumableCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final ConsumableType item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _getIcon() {
    switch (item.name.toLowerCase()) {
      case 'hay':
        return Icons.grass;
      case 'haylage':
        return Icons.eco;
      case 'straw':
        return Icons.agriculture;
      case 'shavings':
        return Icons.blur_on;
      default:
        return Icons.inventory_2_outlined;
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
              item.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (item.brand != null)
              Text(
                item.brand!,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '£${item.pricePerUsageUnit.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'per ${item.usageUnit.toLowerCase()}',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            const Spacer(),
            if (item.trackInventory)
              _buildStockBadge()
            else
              Text(
                'Not tracked',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    final stockDisplay = item.currentStock % 1 == 0
        ? item.currentStock.toInt().toString()
        : item.currentStock.toStringAsFixed(1);
    final stockSuffix = item.currentStock == 1 ? '' : 's';

    Color badgeColor;
    Color textColor;
    if (item.currentStock > 5) {
      badgeColor = Colors.green;
      textColor = Colors.green[700]!;
    } else if (item.currentStock > 0) {
      badgeColor = Colors.orange;
      textColor = Colors.orange[700]!;
    } else {
      badgeColor = Colors.red;
      textColor = Colors.red[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$stockDisplay ${item.stockUnit}$stockSuffix in stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
