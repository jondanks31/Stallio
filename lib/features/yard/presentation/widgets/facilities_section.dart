import 'package:flutter/material.dart';

import '../../data/facilities_repository.dart';
import 'section_header.dart';

/// Section displaying facilities in a responsive grid.
class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({
    super.key,
    required this.facilities,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final List<Facility> facilities;
  final VoidCallback onAdd;
  final void Function(Facility) onEdit;
  final void Function(Facility) onDelete;
  final void Function(Facility) onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Facilities',
          subtitle: 'Manage bookable amenities like arenas and walkers',
          onAdd: onAdd,
        ),
        const SizedBox(height: 24),
        if (facilities.isEmpty)
          _buildEmptyState(context)
        else
          _buildFacilitiesGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fence_outlined,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No facilities yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add arenas, walkers, and other bookable amenities',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Facility'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 3
            : (constraints.maxWidth > 500 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            return _FacilityCard(
              facility: facilities[index],
              onEdit: () => onEdit(facilities[index]),
              onDelete: () => onDelete(facilities[index]),
              onToggleActive: () => onToggleActive(facilities[index]),
            );
          },
        );
      },
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final Facility facility;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  IconData _getTypeIcon() {
    switch (facility.type) {
      case FacilityType.indoorArena:
        return Icons.home_work_outlined;
      case FacilityType.outdoorArena:
        return Icons.grass;
      case FacilityType.roundPen:
        return Icons.circle_outlined;
      case FacilityType.walker:
        return Icons.directions_walk;
      case FacilityType.washBay:
        return Icons.water_drop_outlined;
      case FacilityType.tackRoom:
        return Icons.inventory_2_outlined;
      case FacilityType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: facility.isActive
              ? (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08))
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(),
                  size: 20,
                  color: const Color(0xFFFFD66B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      facility.type.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMenu(isDark),
            ],
          ),
          const Spacer(),
          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.timer_outlined,
                '${facility.slotDurationMinutes} min slots',
                isDark,
              ),
              _buildInfoChip(
                Icons.calendar_today_outlined,
                '${facility.advanceBookingDays} days advance',
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: facility.isActive ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                facility.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: facility.isActive ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'toggle':
            onToggleActive();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                facility.isActive
                    ? Icons.pause_outlined
                    : Icons.play_arrow_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(facility.isActive ? 'Deactivate' : 'Activate'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red[400])),
            ],
          ),
        ),
      ],
    );
  }
}
