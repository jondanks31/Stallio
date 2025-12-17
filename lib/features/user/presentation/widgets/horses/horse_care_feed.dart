import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/billing_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE CARE FEED - Activity timeline for horse care
// ─────────────────────────────────────────────────────────────────────────────

/// Care feed tab showing activity timeline
class HorseCareFeed extends StatelessWidget {
  const HorseCareFeed({
    super.key,
    required this.activities,
    required this.isLoading,
  });

  final List<ConsumableCharge> activities;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activities.isEmpty) {
      return HorseCareFeedEmptyState(isDark: isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return HorseActivityCard(activity: activities[index]);
      },
    );
  }
}

/// Empty state for care feed
class HorseCareFeedEmptyState extends StatelessWidget {
  const HorseCareFeedEmptyState({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Care Feed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A timeline of all care activities for your horse will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual activity card in the care feed
class HorseActivityCard extends StatelessWidget {
  const HorseActivityCard({super.key, required this.activity});

  final ConsumableCharge activity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeAgo = formatTimeAgo(activity.loggedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: Color(0xFFFFD66B),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.consumableName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.quantity.toStringAsFixed(1)} ${activity.unit} • by ${activity.loggedByName ?? 'Staff'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          // Time and cost
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£${activity.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Format a DateTime to a human-readable "time ago" string
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  return DateFormat('d MMM').format(dateTime);
}
