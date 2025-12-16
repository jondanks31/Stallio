import 'package:flutter/material.dart';

import '../../../../../core/ui/branded_dialog.dart';
import '../../../../../core/ui/snackbar_service.dart';
import '../../../../bookings/data/bookings_repository.dart';
import '../../../../horses/data/horse_model.dart';
import 'calendar_common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PERSONAL EVENT WIDGETS - Card and dialogs for personal horse events
// ─────────────────────────────────────────────────────────────────────────────

/// Card displaying a personal event
class PersonalEventCard extends StatelessWidget {
  const PersonalEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final PersonalEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                event.eventType.icon,
                size: 20,
                color: const Color(0xFFE5B800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.displayTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        event.timeString,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      if (event.horseName != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                        Text(
                          event.horseName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows event detail dialog with edit/delete options
/// Returns 'deleted' if event was deleted, 'edited' if edited, null otherwise
Future<String?> showEventDetailDialog({
  required BuildContext context,
  required PersonalEvent event,
  required DateTime selectedDate,
  required List<Horse> horses,
  required BookingsRepository repository,
  required VoidCallback onEventUpdated,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: BrandColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      event.eventType.icon,
                      size: 24,
                      color: const Color(0xFFE5B800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.displayTitle,
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.eventType.displayName,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Event details
              CalendarDetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value:
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              const SizedBox(height: 12),
              CalendarDetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: event.timeString,
              ),
              if (event.horseName != null) ...[
                const SizedBox(height: 12),
                CalendarDetailRow(
                  icon: Icons.pets,
                  label: 'Horse',
                  value: event.horseName!,
                ),
              ],
              if (event.notes != null && event.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                CalendarDetailRow(
                  icon: Icons.notes,
                  label: 'Notes',
                  value: event.notes!,
                ),
              ],
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx, 'delete'),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx, 'edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandColors.yellow,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (result == 'delete') {
    if (!context.mounted) return null;
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Delete Event',
      message:
          'Are you sure you want to delete "${event.displayTitle}"? This cannot be undone.',
    );
    if (confirmed) {
      try {
        await repository.deletePersonalEvent(event.id);
        onEventUpdated();
        if (!context.mounted) return 'deleted';
        SnackbarService.showSuccess(context, 'Event deleted');
        return 'deleted';
      } catch (e) {
        if (!context.mounted) return null;
        SnackbarService.showError(context, 'Failed to delete event');
      }
    }
  } else if (result == 'edit') {
    if (!context.mounted) return null;
    final edited = await showEditEventDialog(
      context: context,
      event: event,
      horses: horses,
      repository: repository,
      onEventUpdated: onEventUpdated,
    );
    return edited ? 'edited' : null;
  }
  return null;
}

/// Shows dialog to edit an existing personal event
Future<bool> showEditEventDialog({
  required BuildContext context,
  required PersonalEvent event,
  required List<Horse> horses,
  required BookingsRepository repository,
  required VoidCallback onEventUpdated,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  PersonalEventType selectedType = event.eventType;
  Horse? selectedHorse = horses.where((h) => h.id == event.horseId).firstOrNull;
  TimeOfDay? selectedTime = event.eventTime;
  final titleController = TextEditingController(text: event.title ?? '');
  final notesController = TextEditingController(text: event.notes ?? '');

  final saved = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark
                ? BrandColors.dialogBgDark
                : BrandColors.dialogBgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Event',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Event type selector
                      _buildEventTypeSelector(
                        selectedType: selectedType,
                        onTypeSelected: (type) {
                          setDialogState(() => selectedType = type);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Time selector
                      _buildTimeSelector(
                        selectedTime: selectedTime,
                        onTimeSelected: (time) {
                          setDialogState(() => selectedTime = time);
                        },
                        isDark: isDark,
                        context: context,
                      ),
                      const SizedBox(height: 16),

                      // Horse selector
                      if (horses.isNotEmpty) ...[
                        _buildHorseSelector(
                          selectedHorse: selectedHorse,
                          horses: horses,
                          onHorseSelected: (horse) {
                            setDialogState(() => selectedHorse = horse);
                          },
                          isDark: isDark,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Custom title
                      TextField(
                        controller: titleController,
                        decoration: brandedInputDecoration(
                          context: context,
                          label: 'Custom Title (optional)',
                          hint: 'e.g., Front shoes only',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: brandedInputDecoration(
                          context: context,
                          label: 'Notes (optional)',
                          hint: 'Any additional notes...',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const DialogCancelButton(),
                          const SizedBox(width: 12),
                          DialogPrimaryButton(
                            label: 'Save',
                            onPressed: () async {
                              final title = titleController.text.isNotEmpty
                                  ? titleController.text
                                  : null;
                              final notes = notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null;
                              Navigator.pop(context, true);
                              try {
                                await repository.updatePersonalEvent(
                                  eventId: event.id,
                                  eventType: selectedType,
                                  eventTime: selectedTime,
                                  horseId: selectedHorse?.id,
                                  title: title,
                                  notes: notes,
                                );
                                onEventUpdated();
                                if (!context.mounted) return;
                                SnackbarService.showSuccess(
                                  context,
                                  'Event updated',
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarService.showError(
                                  context,
                                  'Failed to update event',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  notesController.dispose();
  return saved ?? false;
}

/// Shows dialog to create a new personal event
Future<bool> showCreatePersonalEventDialog({
  required BuildContext context,
  required DateTime selectedDate,
  required List<Horse> horses,
  required BookingsRepository repository,
  required VoidCallback onEventCreated,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  PersonalEventType selectedType = PersonalEventType.farrier;
  Horse? selectedHorse;
  TimeOfDay? selectedTime;
  final titleController = TextEditingController();
  final notesController = TextEditingController();

  final created = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark
                ? BrandColors.dialogBgDark
                : BrandColors.dialogBgLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Personal Event',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Event type selector
                      _buildEventTypeSelector(
                        selectedType: selectedType,
                        onTypeSelected: (type) {
                          setDialogState(() => selectedType = type);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Time selector
                      _buildTimeSelector(
                        selectedTime: selectedTime,
                        onTimeSelected: (time) {
                          setDialogState(() => selectedTime = time);
                        },
                        isDark: isDark,
                        context: context,
                      ),
                      const SizedBox(height: 16),

                      // Horse selector
                      if (horses.isNotEmpty) ...[
                        _buildHorseSelector(
                          selectedHorse: selectedHorse,
                          horses: horses,
                          onHorseSelected: (horse) {
                            setDialogState(() => selectedHorse = horse);
                          },
                          isDark: isDark,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Custom title
                      _buildLabeledField(
                        label: 'Custom Title (optional)',
                        isDark: isDark,
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Front shoes only',
                            filled: true,
                            fillColor: isDark
                                ? Colors.white10
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      _buildLabeledField(
                        label: 'Notes (optional)',
                        isDark: isDark,
                        child: TextField(
                          controller: notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Any additional notes...',
                            filled: true,
                            fillColor: isDark
                                ? Colors.white10
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const DialogCancelButton(),
                          const SizedBox(width: 12),
                          DialogPrimaryButton(
                            label: 'Add Event',
                            onPressed: () async {
                              final title = titleController.text.isNotEmpty
                                  ? titleController.text
                                  : null;
                              final notes = notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null;
                              Navigator.pop(context, true);
                              try {
                                await repository.createPersonalEvent(
                                  eventType: selectedType,
                                  eventDate: selectedDate,
                                  eventTime: selectedTime,
                                  horseId: selectedHorse?.id,
                                  title: title,
                                  notes: notes,
                                );
                                onEventCreated();
                                if (!context.mounted) return;
                                SnackbarService.showSuccess(
                                  context,
                                  'Event added',
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarService.showError(
                                  context,
                                  'Failed to add event',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  notesController.dispose();
  return created ?? false;
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS - Used by event dialogs
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildEventTypeSelector({
  required PersonalEventType selectedType,
  required Function(PersonalEventType) onTypeSelected,
  required bool isDark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Event Type',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PersonalEventType.values.map((type) {
          final isSelected = selectedType == type;
          return GestureDetector(
            onTap: () => onTypeSelected(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD66B)
                    : (isDark ? Colors.white10 : Colors.grey[100]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 16,
                    color: isSelected
                        ? Colors.black87
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.black87
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget _buildTimeSelector({
  required TimeOfDay? selectedTime,
  required Function(TimeOfDay) onTimeSelected,
  required bool isDark,
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Time',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            onTimeSelected(time);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                selectedTime != null
                    ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                    : 'Select time (optional)',
                style: TextStyle(
                  color: selectedTime != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildHorseSelector({
  required Horse? selectedHorse,
  required List<Horse> horses,
  required Function(Horse?) onHorseSelected,
  required bool isDark,
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Horse (optional)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<Horse?>(
        value: selectedHorse,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? Colors.white10 : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        hint: Text(
          'No horse selected',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        ),
        items: [
          DropdownMenuItem<Horse?>(
            value: null,
            child: Text(
              'No horse selected',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ),
          ...horses.map((h) => DropdownMenuItem(value: h, child: Text(h.name))),
        ],
        onChanged: onHorseSelected,
      ),
    ],
  );
}

Widget _buildLabeledField({
  required String label,
  required bool isDark,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}
