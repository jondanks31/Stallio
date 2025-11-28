import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';

/// Stats bar showing counts of active and invited people.
class PeopleStatsBar extends StatelessWidget {
  const PeopleStatsBar({
    super.key,
    required this.activeCount,
    required this.invitedCount,
  });

  final int activeCount;
  final int invitedCount;

  int get _total => activeCount + invitedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate percentages for the bar
    final activePercent = _total > 0 ? activeCount / _total : 0.0;
    final invitedPercent = _total > 0 ? invitedCount / _total : 0.0;

    return Row(
      children: [
        // Progress bar section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Labels row
              Row(
                children: [
                  _buildStatLabel('Active', activeCount, Colors.green, isDark),
                  const SizedBox(width: 24),
                  _buildStatLabel(
                    'Invited',
                    invitedCount,
                    BrandColors.yellow,
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (activePercent > 0)
                      Flexible(
                        flex: (activePercent * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.horizontal(
                              left: const Radius.circular(4),
                              right: invitedPercent == 0
                                  ? const Radius.circular(4)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                    if (invitedPercent > 0)
                      Flexible(
                        flex: (invitedPercent * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.yellow,
                            borderRadius: BorderRadius.horizontal(
                              left: activePercent == 0
                                  ? const Radius.circular(4)
                                  : Radius.zero,
                              right: const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatLabel(String label, int count, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }
}
