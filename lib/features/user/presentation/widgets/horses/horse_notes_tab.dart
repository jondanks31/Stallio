import 'package:flutter/material.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../../horses/data/horse_model.dart';
import '../../../../horses/data/horses_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE NOTES TAB - Editable note sections for horse info
// Note: This will be enhanced later with specialized layouts per tab type:
// - Feed: recipe card layout
// - Care: free text with optional headers
// - Contacts: structured entries (Farrier, Vet, Physio, Emergency)
// - Notes: free text
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for different note tab types
enum HorseNoteType {
  care(
    'medical_notes',
    'Care Instructions',
    Icons.medical_services_outlined,
    'Add special care instructions, medical needs, or daily routines for your horse.',
  ),
  feed(
    'diet_notes',
    'Feed Instructions',
    Icons.restaurant_outlined,
    'Add feeding schedule, dietary requirements, and any food allergies.',
  ),
  behaviour(
    'behaviour_notes',
    'Behaviour Notes',
    Icons.note_outlined,
    'Add notes about temperament, handling tips, or important behaviours.',
  ),
  contacts(
    'notes',
    'General Notes & Contacts',
    Icons.contacts_outlined,
    'Add vet details, farrier contacts, or any other important information.',
  );

  const HorseNoteType(this.field, this.title, this.icon, this.emptyMessage);

  final String field;
  final String title;
  final IconData icon;
  final String emptyMessage;
}

/// Editable note tab for horse information
class HorseNotesTab extends StatelessWidget {
  const HorseNotesTab({
    super.key,
    required this.horse,
    required this.noteType,
    required this.onUpdated,
  });

  final Horse? horse;
  final HorseNoteType noteType;
  final VoidCallback onUpdated;

  String? get _content {
    if (horse == null) return null;
    switch (noteType) {
      case HorseNoteType.care:
        return horse!.medicalNotes;
      case HorseNoteType.feed:
        return horse!.dietNotes;
      case HorseNoteType.behaviour:
        return horse!.behaviourNotes;
      case HorseNoteType.contacts:
        return horse!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (horse == null) {
      return _HorseNotesEmptyState(
        isDark: isDark,
        icon: noteType.icon,
        title: noteType.title,
        description: 'Select a horse to view ${noteType.title}.',
      );
    }

    final hasContent = _content != null && _content!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  noteType.icon,
                  color: const Color(0xFFFFD66B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  noteType.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => showEditNoteDialog(
                  context: context,
                  horse: horse!,
                  noteType: noteType,
                  currentValue: _content,
                  onUpdated: onUpdated,
                ),
                icon: Icon(
                  hasContent ? Icons.edit : Icons.add,
                  size: 18,
                  color: const Color(0xFFFFD66B),
                ),
                label: Text(
                  hasContent ? 'Edit' : 'Add',
                  style: const TextStyle(color: Color(0xFFFFD66B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: hasContent
                ? Text(
                    _content!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  )
                : Column(
                    children: [
                      Icon(
                        noteType.icon,
                        size: 32,
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        noteType.emptyMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no horse is selected
class _HorseNotesEmptyState extends StatelessWidget {
  const _HorseNotesEmptyState({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.description,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String description;

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
                icon,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
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

/// Show dialog to edit a note field
Future<void> showEditNoteDialog({
  required BuildContext context,
  required Horse horse,
  required HorseNoteType noteType,
  required String? currentValue,
  required VoidCallback onUpdated,
}) async {
  final controller = TextEditingController(text: currentValue ?? '');
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final repository = HorsesRepository();

  final result = await showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit ${noteType.title}',
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
              Flexible(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter ${noteType.title}...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      onPressed: () => Navigator.pop(context, controller.text),
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
    ),
  );

  if (result != null && context.mounted) {
    try {
      await repository.updateHorse(horse.id, {
        noteType.field: result.isEmpty ? null : result,
      });
      onUpdated();
      if (context.mounted) {
        SnackbarService.showSuccess(context, '${noteType.title} updated');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(
          context,
          'Failed to update ${noteType.title}',
        );
      }
    }
  }
}
