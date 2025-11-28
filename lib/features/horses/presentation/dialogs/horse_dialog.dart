import 'package:flutter/material.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../data/horse_model.dart';
import '../../data/horses_repository.dart';

/// Dialog for adding or editing a horse
class HorseDialog extends StatefulWidget {
  const HorseDialog({super.key, this.horse});

  /// If provided, dialog is in edit mode
  final Horse? horse;

  bool get isEditing => horse != null;

  @override
  State<HorseDialog> createState() => _HorseDialogState();
}

class _HorseDialogState extends State<HorseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repository = HorsesRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _colorController;
  late final TextEditingController _notesController;

  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final horse = widget.horse;
    _nameController = TextEditingController(text: horse?.name ?? '');
    _colorController = TextEditingController(text: horse?.color ?? '');
    _notesController = TextEditingController(text: horse?.notes ?? '');
    _dateOfBirth = horse?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final color = _colorController.text.trim();
      final notes = _notesController.text.trim();

      Horse result;

      if (widget.isEditing) {
        // Update existing horse
        result = await _repository.updateHorse(widget.horse!.id, {
          'name': name,
          'colour': color.isNotEmpty ? color : null,
          'date_of_birth': _dateOfBirth?.toIso8601String().split('T').first,
          'notes': notes.isNotEmpty ? notes : null,
        });
      } else {
        // Create new horse
        result = await _repository.createHorse(
          name: name,
          color: color.isNotEmpty ? color : null,
          dateOfBirth: _dateOfBirth,
          notes: notes.isNotEmpty ? notes : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          widget.isEditing ? 'Failed to update horse' : 'Failed to add horse',
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now.subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1980),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Color(0xFFFFD66B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isEditing ? 'Edit Horse' : 'Add Horse',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name field (required)
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Enter horse name',
                    isDark: isDark,
                    required: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Color field
                  _buildTextField(
                    controller: _colorController,
                    label: 'Colour',
                    hint: 'e.g. Bay, Chestnut, Grey',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Date of birth picker
                  _buildDatePicker(isDark),
                  const SizedBox(height: 16),

                  // Notes field
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Any additional notes about your horse',
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
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
                          onPressed: _isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD66B),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black54,
                                  ),
                                )
                              : Text(widget.isEditing ? 'Save' : 'Add Horse'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool required = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    final dateText = _dateOfBirth != null
        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      color: _dateOfBirth != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.black26),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Show the horse dialog and return the created/updated horse
Future<Horse?> showHorseDialog(BuildContext context, {Horse? horse}) {
  return showDialog<Horse>(
    context: context,
    builder: (context) => HorseDialog(horse: horse),
  );
}
