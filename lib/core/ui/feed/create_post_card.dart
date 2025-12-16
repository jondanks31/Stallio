import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/feed/data/feed_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE POST CARD - Inline post creation widget
// ─────────────────────────────────────────────────────────────────────────────

/// Inline card for creating new posts.
/// Expands when tapped to allow multi-line input.
class CreatePostCard extends StatefulWidget {
  const CreatePostCard({
    super.key,
    required this.yardId,
    this.onPostCreated,
    this.canCreateAnnouncement = false,
  });

  final String yardId;
  final VoidCallback? onPostCreated;
  final bool canCreateAnnouncement;

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  final _repository = FeedRepository();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isExpanded = false;
  bool _isSubmitting = false;
  bool _isCreatingPoll = false;
  bool _isAnnouncement = false;
  int _announcementHours = 24; // Default 24 hours
  String? _avatarUrl;
  String? _userRole;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptions) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isExpanded) {
      setState(() => _isExpanded = true);
    }
  }

  Future<void> _loadUserProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url, role')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _avatarUrl = profile['avatar_url'] as String?;
          _userRole = profile['role'] as String?;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  bool get _canCreateAnnouncement =>
      _userRole == 'owner' || _userRole == 'manager';

  Future<void> _showCustomDurationPicker(
    BuildContext context,
    bool isDark,
  ) async {
    int hours = 1;
    int days = 0;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Custom Duration',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Days',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: days > 0
                                  ? () => setDialogState(() => days--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$days',
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setDialogState(() => days++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hours',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: hours > 0 || days > 0
                                  ? () => setDialogState(() {
                                      if (hours > 0) {
                                        hours--;
                                      } else if (days > 0) {
                                        days--;
                                        hours = 23;
                                      }
                                    })
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$hours',
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            IconButton(
                              onPressed: hours < 23
                                  ? () => setDialogState(() => hours++)
                                  : () => setDialogState(() {
                                      hours = 0;
                                      days++;
                                    }),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total: ${days > 0 ? "$days day${days > 1 ? 's' : ''} " : ''}${hours > 0 ? "$hours hour${hours > 1 ? 's' : ''}" : ''}',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
            FilledButton(
              onPressed: (days > 0 || hours > 0)
                  ? () => Navigator.pop(context, days * 24 + hours)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
              ),
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _announcementHours = result);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
      });
    }
  }

  void _togglePoll() {
    setState(() {
      _isCreatingPoll = !_isCreatingPoll;
      if (!_isCreatingPoll) {
        _pollQuestionController.clear();
        for (final c in _pollOptions) {
          c.clear();
        }
      }
    });
  }

  void _addPollOption() {
    if (_pollOptions.length < 5) {
      setState(() => _pollOptions.add(TextEditingController()));
    }
  }

  void _removePollOption(int index) {
    if (_pollOptions.length > 2) {
      setState(() {
        _pollOptions[index].dispose();
        _pollOptions.removeAt(index);
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    // Validate poll if creating one
    if (_isCreatingPoll) {
      if (_pollQuestionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a poll question')),
        );
        return;
      }
      final validOptions = _pollOptions
          .where((c) => c.text.trim().isNotEmpty)
          .toList();
      if (validOptions.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least 2 poll options')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      String? pollId;
      String? mediaUrl;

      // Create poll if needed
      if (_isCreatingPoll) {
        final validOptions = _pollOptions
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        pollId = await _repository.createPoll(
          question: _pollQuestionController.text.trim(),
          options: validOptions,
        );
      }

      // Upload image if selected
      if (_selectedImageBytes != null) {
        mediaUrl = await _repository.uploadMediaBytes(
          widget.yardId,
          _selectedImageBytes!,
          _selectedImageName ?? 'image.jpg',
        );
      }

      await _repository.createPost(
        yardId: widget.yardId,
        content: content,
        mediaUrl: mediaUrl,
        mediaType: mediaUrl != null ? 'image' : null,
        pollId: pollId,
        isPinned: _isAnnouncement,
        announcementHours: _isAnnouncement ? _announcementHours : null,
      );

      if (mounted) {
        _controller.clear();
        _pollQuestionController.clear();
        for (final c in _pollOptions) {
          c.clear();
        }
        _focusNode.unfocus();
        setState(() {
          _isExpanded = false;
          _isSubmitting = false;
          _isCreatingPoll = false;
          _isAnnouncement = false;
          _announcementHours = 24;
          _selectedImageBytes = null;
          _selectedImageName = null;
        });
        widget.onPostCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
      }
    }
  }

  void _collapse() {
    if (_controller.text.trim().isEmpty &&
        _selectedImageBytes == null &&
        !_isCreatingPoll) {
      _focusNode.unfocus();
      setState(() => _isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main input row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 20,
                          color: isDark ? Colors.white38 : Colors.black26,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: _isExpanded ? 5 : 1,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onChanged: (_) => setState(() {
                      if (!_isExpanded) _isExpanded = true;
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Selected image preview
          if (_selectedImageBytes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedImageBytes = null;
                        _selectedImageName = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Poll creation UI
          if (_isCreatingPoll)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.poll,
                          size: 18,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Poll',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _togglePoll,
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pollQuestionController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _pollOptions.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pollOptions[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.white10
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            if (_pollOptions.length > 2)
                              IconButton(
                                onPressed: () => _removePollOption(index),
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 18,
                                  color: Colors.red[400],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_pollOptions.length < 5)
                      TextButton.icon(
                        onPressed: _addPollOption,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add option'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD66B),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Announcement options (only when announcement is selected)
          if (_isAnnouncement)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFD66B).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Announcement',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This post will be pinned at the top of the feed.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pin duration:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DurationChip(
                          label: '1h',
                          isSelected: _announcementHours == 1,
                          onTap: () => setState(() => _announcementHours = 1),
                        ),
                        _DurationChip(
                          label: '4h',
                          isSelected: _announcementHours == 4,
                          onTap: () => setState(() => _announcementHours = 4),
                        ),
                        _DurationChip(
                          label: '12h',
                          isSelected: _announcementHours == 12,
                          onTap: () => setState(() => _announcementHours = 12),
                        ),
                        _DurationChip(
                          label: '24h',
                          isSelected: _announcementHours == 24,
                          onTap: () => setState(() => _announcementHours = 24),
                        ),
                        _DurationChip(
                          label: 'Custom',
                          isSelected: ![
                            1,
                            4,
                            12,
                            24,
                          ].contains(_announcementHours),
                          onTap: () =>
                              _showCustomDurationPicker(context, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Action bar (only when expanded)
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _ActionIconButton(
                    icon: _selectedImageBytes != null
                        ? Icons.image
                        : Icons.image_outlined,
                    isDark: isDark,
                    isActive: _selectedImageBytes != null,
                    onTap: _pickImage,
                  ),
                  const SizedBox(width: 4),
                  _ActionIconButton(
                    icon: _isCreatingPoll ? Icons.poll : Icons.poll_outlined,
                    isDark: isDark,
                    isActive: _isCreatingPoll,
                    onTap: _togglePoll,
                  ),
                  if (_canCreateAnnouncement) ...[
                    const SizedBox(width: 4),
                    _ActionIconButton(
                      icon: _isAnnouncement
                          ? Icons.campaign
                          : Icons.campaign_outlined,
                      isDark: isDark,
                      isActive: _isAnnouncement,
                      onTap: () =>
                          setState(() => _isAnnouncement = !_isAnnouncement),
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: _collapse,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting || _controller.text.trim().isEmpty
                        ? null
                        : _submitPost,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD66B),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          )
                        : const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD66B) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD66B)
                : Colors.grey.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? const Color(0xFFFFD66B)
              : (isDark ? Colors.white54 : Colors.black45),
        ),
      ),
    );
  }
}
