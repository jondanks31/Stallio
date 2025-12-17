import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../../horses/data/horse_model.dart';
import '../../../../horses/data/horses_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE CONTACTS TAB - Structured contact entries
// ─────────────────────────────────────────────────────────────────────────────

/// Contact type with defaults
enum HorseContactType {
  vet('Vet', Icons.local_hospital),
  farrier('Farrier', Icons.hardware),
  physio('Physio', Icons.spa),
  dentist('Dentist', Icons.medical_services),
  saddleFitter('Saddle Fitter', Icons.chair),
  instructor('Instructor', Icons.school),
  emergencyContact('Emergency Contact', Icons.emergency),
  insurance('Insurance', Icons.security),
  other('Other', Icons.person);

  const HorseContactType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  static HorseContactType fromString(String value) {
    return HorseContactType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => HorseContactType.other,
    );
  }
}

/// Contact model
class HorseContact {
  final HorseContactType type;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;

  HorseContact({
    required this.type,
    required this.name,
    this.phone,
    this.email,
    this.notes,
  });

  factory HorseContact.fromJson(Map<String, dynamic> json) {
    return HorseContact(
      type: HorseContactType.fromString(json['type'] as String? ?? 'other'),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'phone': phone,
    'email': email,
    'notes': notes,
  };

  HorseContact copyWith({
    HorseContactType? type,
    String? name,
    String? phone,
    String? email,
    String? notes,
  }) {
    return HorseContact(
      type: type ?? this.type,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
    );
  }
}

/// Parse contacts from JSON stored in notes field
List<HorseContact> parseContacts(String? notes) {
  if (notes == null || notes.isEmpty) return [];
  try {
    final decoded = jsonDecode(notes);
    if (decoded is List) {
      return decoded.map((e) => HorseContact.fromJson(e)).toList();
    }
  } catch (_) {
    // Legacy plain text - ignore
  }
  return [];
}

/// Encode contacts to JSON for storage
String encodeContacts(List<HorseContact> contacts) {
  return jsonEncode(contacts.map((c) => c.toJson()).toList());
}

/// Contacts tab with structured entries
class HorseContactsTab extends StatelessWidget {
  const HorseContactsTab({
    super.key,
    required this.horse,
    required this.onUpdated,
  });

  final Horse? horse;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (horse == null) {
      return _ContactsEmptyState(
        isDark: isDark,
        message: 'Select a horse to view Contacts.',
      );
    }

    final contacts = parseContacts(horse!.notes);

    if (contacts.isEmpty) {
      return _ContactsEmptyState(
        isDark: isDark,
        message:
            'Add important contacts for your horse like vet, farrier, and emergency contacts.',
        showAddButton: true,
        onAdd: () => _showAddContactDialog(context),
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
                  Icons.contacts_outlined,
                  color: Color(0xFFFFD66B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showAddContactDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFFFFD66B),
              ),
            ],
          ),
        ),

        // Contact cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _ContactCard(
                contact: contacts[index],
                onEdit: () => _showEditContactDialog(context, index, contacts),
                onDelete: () => _deleteContact(context, index, contacts),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddContactDialog(BuildContext context) async {
    final result = await showDialog<HorseContact>(
      context: context,
      builder: (context) => const _ContactDialog(),
    );

    if (result != null && context.mounted) {
      final contacts = parseContacts(horse!.notes);
      contacts.add(result);
      await _saveContacts(context, contacts);
    }
  }

  Future<void> _showEditContactDialog(
    BuildContext context,
    int index,
    List<HorseContact> contacts,
  ) async {
    final result = await showDialog<HorseContact>(
      context: context,
      builder: (context) => _ContactDialog(contact: contacts[index]),
    );

    if (result != null && context.mounted) {
      contacts[index] = result;
      await _saveContacts(context, contacts);
    }
  }

  Future<void> _deleteContact(
    BuildContext context,
    int index,
    List<HorseContact> contacts,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
          'Are you sure you want to delete "${contacts[index].name}"?',
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
      contacts.removeAt(index);
      await _saveContacts(context, contacts);
    }
  }

  Future<void> _saveContacts(
    BuildContext context,
    List<HorseContact> contacts,
  ) async {
    final repository = HorsesRepository();
    try {
      await repository.updateHorse(horse!.id, {
        'notes': encodeContacts(contacts),
      });
      onUpdated();
      if (context.mounted) {
        SnackbarService.showSuccess(context, 'Contacts updated');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, 'Failed to update');
      }
    }
  }
}

/// Individual contact card
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  final HorseContact contact;
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                contact.type.icon,
                color: const Color(0xFFFFD66B),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (contact.phone != null && contact.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          contact.phone!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (contact.email != null && contact.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (contact.notes != null && contact.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      contact.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
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
          ],
        ),
      ),
    );
  }
}

/// Empty state for contacts tab
class _ContactsEmptyState extends StatelessWidget {
  const _ContactsEmptyState({
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
                  Icons.contacts_outlined,
                  size: 40,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Contacts',
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
                  label: const Text('Add Contact'),
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

/// Dialog for adding/editing a contact
class _ContactDialog extends StatefulWidget {
  const _ContactDialog({this.contact});

  final HorseContact? contact;

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late HorseContactType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.contact?.type ?? HorseContactType.vet;
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a name');
      return;
    }

    Navigator.pop(
      context,
      HorseContact(
        type: _selectedType,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.contact != null;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
        child: SingleChildScrollView(
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
                      isEditing ? 'Edit Contact' : 'Add Contact',
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

              // Contact type
              Text(
                'Contact Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HorseContactType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(type.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type);
                    },
                    selectedColor: const Color(
                      0xFFFFD66B,
                    ).withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Contact name',
                isDark: isDark,
                required: true,
              ),
              const SizedBox(height: 12),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Phone number',
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Email address',
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Any additional notes...',
                isDark: isDark,
                maxLines: 2,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }
}
