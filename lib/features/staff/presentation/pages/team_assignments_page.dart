import 'package:flutter/material.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../../people/data/people_repository.dart';
import '../../data/staff_repository.dart';

/// Team assignments page for managers/owners.
/// Allows assigning horses to staff members.
class TeamAssignmentsPage extends StatefulWidget {
  const TeamAssignmentsPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<TeamAssignmentsPage> createState() => _TeamAssignmentsPageState();
}

class _TeamAssignmentsPageState extends State<TeamAssignmentsPage> {
  final _staffRepository = StaffRepository();
  final _peopleRepository = PeopleRepository();

  List<YardPerson> _staffMembers = [];
  List<StaffAssignment> _assignments = [];
  List<HorseForLog> _horses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final people = await _peopleRepository.getPeopleInYard(widget.yardId);
      final assignments = await _staffRepository.getYardAssignments(
        widget.yardId,
      );
      final horses = await _staffRepository.getHorsesForLogging(widget.yardId);

      if (mounted) {
        setState(() {
          // Filter to only staff members
          _staffMembers = people
              .where(
                (p) =>
                    p.status == PersonStatus.active &&
                    (p.role == YardRole.staff || p.role == YardRole.manager),
              )
              .toList();
          _assignments = assignments;
          _horses = horses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load team data');
      }
    }
  }

  void _showAssignHorsesDialog(YardPerson staff) {
    // Get currently assigned horse IDs for this staff member
    final assignedHorseIds = _assignments
        .where((a) => a.staffUserId == staff.id)
        .map((a) => a.horseId)
        .toSet();

    final selectedHorseIds = Set<String>.from(assignedHorseIds);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFFD66B),
                            child: Text(
                              (staff.fullName ?? 'S')[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff.fullName ?? 'Staff Member',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Assign horses',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    // Horse list
                    Flexible(
                      child: _horses.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No horses in the yard',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _horses.length,
                              itemBuilder: (context, index) {
                                final horse = _horses[index];
                                final isSelected = selectedHorseIds.contains(
                                  horse.id,
                                );

                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        selectedHorseIds.add(horse.id);
                                      } else {
                                        selectedHorseIds.remove(horse.id);
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFFFFD66B),
                                  checkColor: Colors.black87,
                                  title: Text(
                                    horse.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    horse.ownerName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                  ),
                                  secondary: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.grey[200],
                                    ),
                                    child: horse.photoUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              horse.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    Icons.pets,
                                                    size: 20,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : Colors.black26,
                                                  ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.pets,
                                            size: 20,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.black26,
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${selectedHorseIds.length} horses selected',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _saveAssignments(
                                staff.id,
                                assignedHorseIds,
                                selectedHorseIds,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD66B),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveAssignments(
    String staffUserId,
    Set<String> previousIds,
    Set<String> newIds,
  ) async {
    try {
      // Remove unselected horses
      for (final horseId in previousIds) {
        if (!newIds.contains(horseId)) {
          await _staffRepository.unassignHorse(
            staffUserId: staffUserId,
            horseId: horseId,
          );
        }
      }

      // Add newly selected horses
      for (final horseId in newIds) {
        if (!previousIds.contains(horseId)) {
          await _staffRepository.assignHorseToStaff(
            yardId: widget.yardId,
            staffUserId: staffUserId,
            horseId: horseId,
          );
        }
      }

      await _loadData();
      if (mounted) {
        SnackbarService.showSuccess(context, 'Assignments updated');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update assignments');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Team Assignments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey[200],
                foregroundColor: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Assign horses to staff members for quick logging',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 24),

        // Staff list
        Expanded(
          child: _staffMembers.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    itemCount: _staffMembers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildStaffCard(_staffMembers[index], isDark);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No staff members yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite staff members to assign horses to them',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(YardPerson staff, bool isDark) {
    // Get assignments for this staff member
    final staffAssignments = _assignments
        .where((a) => a.staffUserId == staff.id)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFD66B),
                  backgroundImage: staff.avatarUrl != null
                      ? NetworkImage(staff.avatarUrl!)
                      : null,
                  child: staff.avatarUrl == null
                      ? Text(
                          (staff.fullName ?? 'S')[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName ?? 'Staff Member',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: staff.role == YardRole.manager
                                  ? Colors.purple.withValues(alpha: 0.15)
                                  : Colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              staff.role.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: staff.role == YardRole.manager
                                    ? Colors.purple
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${staffAssignments.length} horses assigned',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAssignHorsesDialog(staff),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Assign'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            // Show assigned horses
            if (staffAssignments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: staffAssignments.map((assignment) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          assignment.horseName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
