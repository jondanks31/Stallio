import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../../horses/data/horse_model.dart';
import '../../../../horses/data/horses_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE FEED TAB - Recipe card layout for feeding instructions
// ─────────────────────────────────────────────────────────────────────────────

/// Feed schedule model
class FeedSchedule {
  final String time; // e.g., "Morning", "Afternoon", "Evening"
  final String instructions;
  final List<String> items; // Feed items/ingredients

  FeedSchedule({
    required this.time,
    this.instructions = '',
    this.items = const [],
  });

  factory FeedSchedule.fromJson(Map<String, dynamic> json) {
    return FeedSchedule(
      time: json['time'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'instructions': instructions,
    'items': items,
  };

  FeedSchedule copyWith({
    String? time,
    String? instructions,
    List<String>? items,
  }) {
    return FeedSchedule(
      time: time ?? this.time,
      instructions: instructions ?? this.instructions,
      items: items ?? this.items,
    );
  }
}

/// Parse feed schedules from JSON stored in diet_notes
List<FeedSchedule> parseFeedSchedules(String? dietNotes) {
  if (dietNotes == null || dietNotes.isEmpty) return [];
  try {
    final decoded = jsonDecode(dietNotes);
    if (decoded is List) {
      return decoded.map((e) => FeedSchedule.fromJson(e)).toList();
    }
  } catch (_) {
    // If not JSON, return empty (legacy plain text will show in empty state)
  }
  return [];
}

/// Encode feed schedules to JSON for storage
String encodeFeedSchedules(List<FeedSchedule> schedules) {
  return jsonEncode(schedules.map((s) => s.toJson()).toList());
}

/// Feed Instructions tab with recipe card layout
class HorseFeedTab extends StatelessWidget {
  const HorseFeedTab({super.key, required this.horse, required this.onUpdated});

  final Horse? horse;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (horse == null) {
      return _FeedEmptyState(
        isDark: isDark,
        message: 'Select a horse to view Feed Instructions.',
      );
    }

    final schedules = parseFeedSchedules(horse!.dietNotes);

    if (schedules.isEmpty) {
      return _FeedEmptyState(
        isDark: isDark,
        message: 'Add feeding times and instructions for your horse.',
        showAddButton: true,
        onAdd: () => _showAddScheduleDialog(context),
      );
    }

    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  color: Color(0xFFFFD66B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Feed Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showAddScheduleDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFFFFD66B),
              ),
            ],
          ),
        ),

        // Schedule cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              return _FeedScheduleCard(
                schedule: schedules[index],
                onEdit: () =>
                    _showEditScheduleDialog(context, index, schedules),
                onDelete: () => _deleteSchedule(context, index, schedules),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddScheduleDialog(BuildContext context) async {
    final result = await showDialog<FeedSchedule>(
      context: context,
      builder: (context) => _FeedScheduleDialog(),
    );

    if (result != null && context.mounted) {
      final schedules = parseFeedSchedules(horse!.dietNotes);
      schedules.add(result);
      await _saveSchedules(context, schedules);
    }
  }

  Future<void> _showEditScheduleDialog(
    BuildContext context,
    int index,
    List<FeedSchedule> schedules,
  ) async {
    final result = await showDialog<FeedSchedule>(
      context: context,
      builder: (context) => _FeedScheduleDialog(schedule: schedules[index]),
    );

    if (result != null && context.mounted) {
      schedules[index] = result;
      await _saveSchedules(context, schedules);
    }
  }

  Future<void> _deleteSchedule(
    BuildContext context,
    int index,
    List<FeedSchedule> schedules,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feed Time?'),
        content: Text(
          'Are you sure you want to delete "${schedules[index].time}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      schedules.removeAt(index);
      await _saveSchedules(context, schedules);
    }
  }

  Future<void> _saveSchedules(
    BuildContext context,
    List<FeedSchedule> schedules,
  ) async {
    final repository = HorsesRepository();
    try {
      await repository.updateHorse(horse!.id, {
        'diet_notes': encodeFeedSchedules(schedules),
      });
      onUpdated();
      if (context.mounted) {
        SnackbarService.showSuccess(context, 'Feed schedule updated');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, 'Failed to update');
      }
    }
  }
}

/// Individual feed schedule card
class _FeedScheduleCard extends StatelessWidget {
  const _FeedScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _timeIcon {
    final lower = schedule.time.toLowerCase();
    if (lower.contains('morning') || lower.contains('am')) {
      return Icons.wb_sunny_outlined;
    } else if (lower.contains('afternoon') || lower.contains('noon')) {
      return Icons.wb_cloudy_outlined;
    } else if (lower.contains('evening') ||
        lower.contains('night') ||
        lower.contains('pm')) {
      return Icons.nightlight_outlined;
    }
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(_timeIcon, size: 20, color: const Color(0xFFFFD66B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    schedule.time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Items list
          if (schedule.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feed Items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: schedule.items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Instructions
          if (schedule.instructions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    schedule.instructions,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          if (schedule.items.isEmpty && schedule.instructions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tap edit to add feed items and instructions',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty state for feed tab
class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({
    required this.isDark,
    required this.message,
    this.showAddButton = false,
    this.onAdd,
  });

  final bool isDark;
  final String message;
  final bool showAddButton;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
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
                  Icons.restaurant_outlined,
                  size: 40,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Feed Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
              if (showAddButton && onAdd != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Feed Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding/editing a feed schedule
class _FeedScheduleDialog extends StatefulWidget {
  const _FeedScheduleDialog({this.schedule});

  final FeedSchedule? schedule;

  @override
  State<_FeedScheduleDialog> createState() => _FeedScheduleDialogState();
}

class _FeedScheduleDialogState extends State<_FeedScheduleDialog> {
  late TextEditingController _timeController;
  late TextEditingController _instructionsController;
  late TextEditingController _itemController;
  late List<String> _items;
  String? _errorMessage;

  static const _suggestedTimes = [
    'Morning (AM)',
    'Midday',
    'Afternoon',
    'Evening (PM)',
  ];

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.schedule?.time ?? '');
    _instructionsController = TextEditingController(
      text: widget.schedule?.instructions ?? '',
    );
    _itemController = TextEditingController();
    _items = List.from(widget.schedule?.items ?? []);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _instructionsController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _addItem() {
    final item = _itemController.text.trim();
    if (item.isNotEmpty && !_items.contains(item)) {
      setState(() {
        _items.add(item);
        _itemController.clear();
      });
    }
  }

  void _removeItem(String item) {
    setState(() => _items.remove(item));
  }

  void _save() {
    if (_timeController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a feed time');
      return;
    }

    Navigator.pop(
      context,
      FeedSchedule(
        time: _timeController.text.trim(),
        instructions: _instructionsController.text.trim(),
        items: _items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.schedule != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (fixed)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Feed Time' : 'Add Feed Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
              const SizedBox(height: 16),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time field with suggestions
                      Text(
                        'Feed Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Morning (7am)',
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _suggestedTimes.map((time) {
                          return ActionChip(
                            label: Text(
                              time,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => _timeController.text = time,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Feed items
                      Text(
                        'Feed Items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _itemController,
                              decoration: InputDecoration(
                                hintText: 'e.g., 2 scoops feed',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              onSubmitted: (_) => _addItem(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add_circle),
                            color: const Color(0xFFFFD66B),
                          ),
                        ],
                      ),
                      if (_items.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _items.map((item) {
                            return Chip(
                              label: Text(item),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeItem(item),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Instructions
                      Text(
                        'Instructions (optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Any special instructions...',
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Buttons (fixed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD66B),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
