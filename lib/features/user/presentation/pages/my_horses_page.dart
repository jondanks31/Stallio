import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../../horses/data/horse_model.dart';
import '../../../horses/data/horses_repository.dart';
import '../../../horses/presentation/dialogs/horse_dialog.dart';
import '../../data/billing_repository.dart';

/// My Horses page for regular yard members.
/// Shows horse selector, avatar, care feed, and tabs for care instructions.
class MyHorsesPage extends StatefulWidget {
  const MyHorsesPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<MyHorsesPage> createState() => _MyHorsesPageState();
}

class _MyHorsesPageState extends State<MyHorsesPage>
    with SingleTickerProviderStateMixin {
  final _repository = HorsesRepository();
  final _billingRepository = BillingRepository();
  late TabController _tabController;

  List<Horse> _horses = [];
  int _selectedHorseIndex = 0;
  bool _isLoading = true;

  // Horse activity
  List<ConsumableCharge> _horseActivity = [];
  bool _activityLoading = false;

  static const _tabs = [
    'Care Feed',
    'Care Instructions',
    'Feed Instructions',
    'Notes',
    'Contacts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadHorses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHorses() async {
    setState(() => _isLoading = true);
    try {
      final horses = await _repository.getMyHorses();
      if (mounted) {
        setState(() {
          _horses = horses;
          _isLoading = false;
          // Reset selection if out of bounds
          if (_selectedHorseIndex >= _horses.length) {
            _selectedHorseIndex = _horses.isEmpty ? 0 : _horses.length - 1;
          }
        });
        // Load activity for selected horse
        _loadHorseActivity();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHorseActivity() async {
    final horse = _selectedHorse;
    if (horse == null) return;

    setState(() => _activityLoading = true);
    try {
      final activity = await _billingRepository.getHorseActivity(horse.id);
      if (mounted) {
        setState(() {
          _horseActivity = activity;
          _activityLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _activityLoading = false);
      }
    }
  }

  Future<void> _addHorse() async {
    final result = await showHorseDialog(context);
    if (result != null) {
      await _loadHorses();
      // Select the newly added horse
      final index = _horses.indexWhere((h) => h.id == result.id);
      if (index >= 0) {
        setState(() => _selectedHorseIndex = index);
      }
    }
  }

  Future<void> _editHorse(Horse horse) async {
    final result = await showHorseDialog(context, horse: horse);
    if (result != null) {
      await _loadHorses();
    }
  }

  Future<void> _uploadPhoto(Horse horse) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (horse.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    if (source == null && horse.photoUrl != null) {
      // User chose to remove photo
      try {
        await _repository.deleteHorsePhoto(horse.id);
        await _loadHorses();
        if (mounted) {
          SnackbarService.showSuccess(context, 'Photo removed');
        }
      } catch (e) {
        if (mounted) {
          SnackbarService.showError(context, 'Failed to remove photo');
        }
      }
      return;
    }

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    try {
      await _repository.uploadHorsePhoto(horse.id, File(pickedFile.path));
      await _loadHorses();
      if (mounted) {
        SnackbarService.showSuccess(context, 'Photo updated');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to upload photo');
      }
    }
  }

  Horse? get _selectedHorse =>
      _horses.isNotEmpty && _selectedHorseIndex < _horses.length
      ? _horses[_selectedHorseIndex]
      : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state - no horses yet
    if (_horses.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        // Horse selector pill
        _buildHorseSelector(isDark),
        const SizedBox(height: 24),

        // Horse avatar
        _buildHorseAvatar(isDark),
        const SizedBox(height: 24),

        // Tab bar
        _buildTabBar(isDark),
        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCareFeed(isDark),
              _buildCareInstructions(isDark),
              _buildFeedInstructions(isDark),
              _buildNotes(isDark),
              _buildContacts(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 64, color: Color(0xFFFFD66B)),
            ),
            const SizedBox(height: 24),
            Text(
              'No horses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first horse to get started',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addHorse,
              icon: const Icon(Icons.add),
              label: const Text('Add Horse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseSelector(bool isDark) {
    final horse = _selectedHorse;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Horse selector dropdown
            PopupMenuButton<int>(
              onSelected: (index) {
                setState(() => _selectedHorseIndex = index);
                _loadHorseActivity(); // Reload activity for new horse
              },
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              itemBuilder: (context) => [
                for (int i = 0; i < _horses.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 18,
                          color: i == _selectedHorseIndex
                              ? const Color(0xFFFFD66B)
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _horses[i].name,
                          style: TextStyle(
                            fontWeight: i == _selectedHorseIndex
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      horse?.name ?? 'Select horse',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Add horse button
            GestureDetector(
              onTap: _addHorse,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseAvatar(bool isDark) {
    final horse = _selectedHorse;

    return GestureDetector(
      onTap: horse != null ? () => _editHorse(horse) : null,
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    border: Border.all(
                      color: const Color(0xFFFFD66B),
                      width: 3,
                    ),
                  ),
                  child: horse?.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            horse!.photoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.pets,
                              size: 48,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          size: 48,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                ),
                if (horse != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _uploadPhoto(horse),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD66B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              horse?.name ?? 'No horse selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            if (horse != null)
              Text(
                _buildHorseSubtitle(horse),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              )
            else
              Text(
                'Add a horse to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildHorseSubtitle(Horse horse) {
    final parts = <String>[];
    if (horse.color != null) parts.add(horse.color!);
    if (horse.age != null) parts.add(horse.ageDisplay);
    return parts.isEmpty ? 'Tap to edit details' : parts.join(' • ');
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.03, 0.92, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black45,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFFFFD66B),
            borderRadius: BorderRadius.circular(999),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildCareFeed(bool isDark) {
    if (_activityLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_horseActivity.isEmpty) {
      return _buildEmptyTabContent(
        isDark,
        Icons.history,
        'Care Feed',
        'A timeline of all care activities for your horse will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _horseActivity.length,
      itemBuilder: (context, index) {
        final activity = _horseActivity[index];
        return _buildActivityCard(activity, isDark);
      },
    );
  }

  Widget _buildActivityCard(ConsumableCharge activity, bool isDark) {
    final timeAgo = _formatTimeAgo(activity.loggedAt);

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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('d MMM').format(dateTime);
  }

  Widget _buildCareInstructions(bool isDark) {
    final horse = _selectedHorse;
    final content = horse?.medicalNotes;

    return _buildEditableNoteCard(
      isDark: isDark,
      icon: Icons.medical_services_outlined,
      title: 'Care Instructions',
      content: content,
      emptyMessage:
          'Add special care instructions, medical needs, or daily routines for your horse.',
      field: 'medical_notes',
    );
  }

  Widget _buildFeedInstructions(bool isDark) {
    final horse = _selectedHorse;
    final content = horse?.dietNotes;

    return _buildEditableNoteCard(
      isDark: isDark,
      icon: Icons.restaurant_outlined,
      title: 'Feed Instructions',
      content: content,
      emptyMessage:
          'Add feeding schedule, dietary requirements, and any food allergies.',
      field: 'diet_notes',
    );
  }

  Widget _buildNotes(bool isDark) {
    final horse = _selectedHorse;
    final content = horse?.behaviourNotes;

    return _buildEditableNoteCard(
      isDark: isDark,
      icon: Icons.note_outlined,
      title: 'Behaviour Notes',
      content: content,
      emptyMessage:
          'Add notes about temperament, handling tips, or important behaviours.',
      field: 'behaviour_notes',
    );
  }

  Widget _buildContacts(bool isDark) {
    final horse = _selectedHorse;
    final content = horse?.notes;

    return _buildEditableNoteCard(
      isDark: isDark,
      icon: Icons.contacts_outlined,
      title: 'General Notes & Contacts',
      content: content,
      emptyMessage:
          'Add vet details, farrier contacts, or any other important information.',
      field: 'notes',
    );
  }

  Widget _buildEditableNoteCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String? content,
    required String emptyMessage,
    required String field,
  }) {
    final hasContent = content != null && content.isNotEmpty;
    final horse = _selectedHorse;

    if (horse == null) {
      return _buildEmptyTabContent(
        isDark,
        icon,
        title,
        'Select a horse to view $title.',
      );
    }

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
                child: Icon(icon, color: const Color(0xFFFFD66B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _editNote(field, title, content),
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
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  )
                : Column(
                    children: [
                      Icon(
                        icon,
                        size: 32,
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        emptyMessage,
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

  Future<void> _editNote(
    String field,
    String title,
    String? currentValue,
  ) async {
    final horse = _selectedHorse;
    if (horse == null) return;

    final controller = TextEditingController(text: currentValue ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        'Edit $title',
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
                      hintText: 'Enter $title...',
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
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
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

    if (result != null && mounted) {
      try {
        await _repository.updateHorse(horse.id, {
          field: result.isEmpty ? null : result,
        });
        await _loadHorses();
        if (mounted) {
          SnackbarService.showSuccess(context, '$title updated');
        }
      } catch (e) {
        if (mounted) {
          SnackbarService.showError(context, 'Failed to update $title');
        }
      }
    }
  }

  Widget _buildEmptyTabContent(
    bool isDark,
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
