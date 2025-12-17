import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../../horses/data/horse_model.dart';
import '../../../../horses/data/horses_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE CARE TAB - Free text with optional section headers
// ─────────────────────────────────────────────────────────────────────────────

/// Care section model
class CareSection {
  final String title;
  final String content;

  CareSection({required this.title, required this.content});

  factory CareSection.fromJson(Map<String, dynamic> json) {
    return CareSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'content': content};
}

/// Suggested section headers
const careSectionSuggestions = [
  'Daily Routine',
  'Medical Conditions',
  'Medications',
  'Turnout',
  'Rugging',
  'Exercise',
  'Special Needs',
  'Allergies',
];

/// Parse care sections from JSON stored in medical_notes
List<CareSection> parseCareSections(String? medicalNotes) {
  if (medicalNotes == null || medicalNotes.isEmpty) return [];
  try {
    final decoded = jsonDecode(medicalNotes);
    if (decoded is List) {
      return decoded.map((e) => CareSection.fromJson(e)).toList();
    }
  } catch (_) {
    // Legacy plain text - convert to single section
    return [CareSection(title: 'General', content: medicalNotes)];
  }
  return [];
}

/// Encode care sections to JSON for storage
String encodeCareSections(List<CareSection> sections) {
  return jsonEncode(sections.map((s) => s.toJson()).toList());
}

/// Care Instructions tab with section headers
class HorseCareTab extends StatelessWidget {
  const HorseCareTab({super.key, required this.horse, required this.onUpdated});

  final Horse? horse;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (horse == null) {
      return _CareEmptyState(
        isDark: isDark,
        message: 'Select a horse to view Care Instructions.',
      );
    }

    final sections = parseCareSections(horse!.medicalNotes);

    if (sections.isEmpty) {
      return _CareEmptyState(
        isDark: isDark,
        message:
            'Add care instructions, medical needs, and daily routines for your horse.',
        showAddButton: true,
        onAdd: () => _showAddSectionDialog(context),
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
                  Icons.medical_services_outlined,
                  color: Color(0xFFFFD66B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Care Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showAddSectionDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFFFFD66B),
              ),
            ],
          ),
        ),

        // Section cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return _CareSectionCard(
                section: sections[index],
                onEdit: () => _showEditSectionDialog(context, index, sections),
                onDelete: () => _deleteSection(context, index, sections),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddSectionDialog(BuildContext context) async {
    final result = await showDialog<CareSection>(
      context: context,
      builder: (context) => const _CareSectionDialog(),
    );

    if (result != null && context.mounted) {
      final sections = parseCareSections(horse!.medicalNotes);
      sections.add(result);
      await _saveSections(context, sections);
    }
  }

  Future<void> _showEditSectionDialog(
    BuildContext context,
    int index,
    List<CareSection> sections,
  ) async {
    final result = await showDialog<CareSection>(
      context: context,
      builder: (context) => _CareSectionDialog(section: sections[index]),
    );

    if (result != null && context.mounted) {
      sections[index] = result;
      await _saveSections(context, sections);
    }
  }

  Future<void> _deleteSection(
    BuildContext context,
    int index,
    List<CareSection> sections,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Section?'),
        content: Text(
          'Are you sure you want to delete "${sections[index].title}"?',
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
      sections.removeAt(index);
      await _saveSections(context, sections);
    }
  }

  Future<void> _saveSections(
    BuildContext context,
    List<CareSection> sections,
  ) async {
    final repository = HorsesRepository();
    try {
      await repository.updateHorse(horse!.id, {
        'medical_notes': encodeCareSections(sections),
      });
      onUpdated();
      if (context.mounted) {
        SnackbarService.showSuccess(context, 'Care instructions updated');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, 'Failed to update');
      }
    }
  }
}

/// Individual care section card
class _CareSectionCard extends StatelessWidget {
  const _CareSectionCard({
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  final CareSection section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                const Icon(
                  Icons.medical_services_outlined,
                  size: 18,
                  color: Color(0xFFFFD66B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 15,
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

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              section.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state for care tab
class _CareEmptyState extends StatelessWidget {
  const _CareEmptyState({
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
                  Icons.medical_services_outlined,
                  size: 40,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Care Instructions',
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
                  label: const Text('Add Section'),
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

/// Dialog for adding/editing a care section
class _CareSectionDialog extends StatefulWidget {
  const _CareSectionDialog({this.section});

  final CareSection? section;

  @override
  State<_CareSectionDialog> createState() => _CareSectionDialogState();
}

class _CareSectionDialogState extends State<_CareSectionDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section?.title ?? '');
    _contentController = TextEditingController(
      text: widget.section?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a section title');
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter content');
      return;
    }

    Navigator.pop(
      context,
      CareSection(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.section != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Section' : 'Add Section',
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

              // Title field
              Text(
                'Section Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Daily Routine',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),

              // Suggestions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: careSectionSuggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _titleController.text = suggestion,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Content field
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Enter care instructions...',
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
                    height: 1.5,
                  ),
                ),
              ),
              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
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

              // Buttons
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
