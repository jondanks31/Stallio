import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/feed/data/feed_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME HEADER - Greeting + Weather (used on User Home, Owner Dashboard)
// ─────────────────────────────────────────────────────────────────────────────

/// Welcome header with personalized greeting and weather widget.
/// Used on User's Home page and Owner's Dashboard page.
class WelcomeHeader extends StatefulWidget {
  const WelcomeHeader({super.key, this.subtitle = 'Welcome to your yard'});

  final String subtitle;

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  final _supabase = Supabase.instance.client;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        final fullName = profile['full_name'] as String?;
        setState(() {
          _firstName = fullName?.split(' ').first ?? 'there';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _firstName = 'there');
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, ${_firstName ?? '...'}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
        // Weather widget
        const WeatherWidget(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEATHER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Weather widget showing current conditions.
/// Reusable across different pages.
class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
              : [const Color(0xFF87CEEB), const Color(0xFF5BA3D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Weather icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wb_sunny, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Weather info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '-- °C',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Weather data coming soon',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  'Your Yard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

/// Section header with icon and title.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENTS SECTION
// ─────────────────────────────────────────────────────────────────────────────

/// Announcements section with pinned posts.
/// Only renders when there are announcements - no empty state.
class AnnouncementsSection extends StatefulWidget {
  const AnnouncementsSection({super.key, required this.yardId});

  final String yardId;

  @override
  State<AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<AnnouncementsSection> {
  final _repository = FeedRepository();
  List<FeedPost> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final announcements = await _repository.getAnnouncements(widget.yardId);
      if (mounted) {
        setState(() {
          _announcements = announcements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Don't render anything if no announcements
    if (!_isLoading && _announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ..._announcements.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnnouncementCard(
                post: post,
                isDark: isDark,
                onPostUpdated: _loadAnnouncements,
                onCommentTap: () => CommentsSheet.show(context, post.id),
              ),
            ),
          ),
      ],
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL FEED SECTION
// ─────────────────────────────────────────────────────────────────────────────

/// Social feed section with post cards.
class SocialFeedSection extends StatefulWidget {
  const SocialFeedSection({super.key, required this.yardId});

  final String yardId;

  @override
  SocialFeedSectionState createState() => SocialFeedSectionState();
}

class SocialFeedSectionState extends State<SocialFeedSection> {
  final _repository = FeedRepository();
  List<FeedPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Public refresh method for parent widgets to call
  void refresh() {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _repository.getFeedPosts(widget.yardId);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Yard Feed',
          icon: Icons.dynamic_feed_outlined,
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_posts.isEmpty)
          _EmptyFeedState(isDark: isDark)
        else
          ..._posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FeedPostCard(
                post: post,
                isDark: isDark,
                onLikeChanged: _loadPosts,
                onCommentTap: () => CommentsSheet.show(context, post.id),
                onPostDeleted: _loadPosts,
              ),
            ),
          ),
      ],
    );
  }
}

/// Announcement card with edit/delete options for creators
class _AnnouncementCard extends StatefulWidget {
  const _AnnouncementCard({
    required this.post,
    required this.isDark,
    this.onPostUpdated,
    this.onCommentTap,
  });

  final FeedPost post;
  final bool isDark;
  final VoidCallback? onPostUpdated;
  final VoidCallback? onCommentTap;

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  final _repository = FeedRepository();
  late bool _hasLiked;
  late int _likeCount;
  bool _isLiking = false;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;
  bool get _isOwnPost => widget.post.authorId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _hasLiked = widget.post.hasLiked;
    _likeCount = widget.post.likeCount;
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);

    try {
      if (_hasLiked) {
        await _repository.unlikePost(widget.post.id);
        if (mounted) {
          setState(() {
            _hasLiked = false;
            _likeCount--;
          });
        }
      } else {
        await _repository.likePost(widget.post.id);
        if (mounted) {
          setState(() {
            _hasLiked = true;
            _likeCount++;
          });
        }
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  String get _expiresIn {
    if (widget.post.announcementExpiresAt == null) return '';
    final diff = widget.post.announcementExpiresAt!.difference(DateTime.now());
    if (diff.inDays > 0) return 'Expires in ${diff.inDays}d';
    if (diff.inHours > 0) return 'Expires in ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Expires in ${diff.inMinutes}m';
    return 'Expiring soon';
  }

  Future<void> _deleteAnnouncement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement?'),
        content: const Text('This will permanently delete this announcement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _repository.deletePost(widget.post.id);
        widget.onPostUpdated?.call();
      } catch (e) {
        // Ignore
      }
    }
  }

  Future<void> _editAnnouncement() async {
    final controller = TextEditingController(text: widget.post.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Edit Announcement',
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Announcement content',
            filled: true,
            fillColor: widget.isDark ? Colors.white10 : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD66B),
              foregroundColor: Colors.black87,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && result != widget.post.content) {
      try {
        await _repository.updatePost(widget.post.id, content: result);
        widget.onPostUpdated?.call();
      } catch (e) {
        // Ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD66B).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Announcement header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign, size: 18, color: Color(0xFFFFD66B)),
                const SizedBox(width: 8),
                Text(
                  'Announcement',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  _expiresIn,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                if (_isOwnPost) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _editAnnouncement();
                      if (value == 'delete') _deleteAnnouncement();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
          // Author info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                  backgroundImage: post.authorAvatarUrl != null
                      ? NetworkImage(post.authorAvatarUrl!)
                      : null,
                  child: post.authorAvatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 18,
                          color: isDark ? Colors.white38 : Colors.black26,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.authorRole != AuthorRole.user) ...[
                            const SizedBox(width: 6),
                            _RoleBadge(role: post.authorRole),
                          ],
                        ],
                      ),
                      Text(
                        post.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              post.content,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          // Media
          if (post.mediaUrl != null)
            ClipRRect(
              child: Image.network(
                post.mediaUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _hasLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _hasLiked
                            ? Colors.red
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likeCount',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feed post card widget with social features.
class FeedPostCard extends StatefulWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.isDark,
    this.onLikeChanged,
    this.onCommentTap,
    this.onPostDeleted,
  });

  final FeedPost post;
  final bool isDark;
  final VoidCallback? onLikeChanged;
  final VoidCallback? onCommentTap;
  final VoidCallback? onPostDeleted;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final _repository = FeedRepository();
  late bool _hasLiked;
  late int _likeCount;
  bool _isLiking = false;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;
  bool get _isOwnPost => widget.post.authorId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _hasLiked = widget.post.hasLiked;
    _likeCount = widget.post.likeCount;
  }

  @override
  void didUpdateWidget(FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _hasLiked = widget.post.hasLiked;
      _likeCount = widget.post.likeCount;
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);

    try {
      if (_hasLiked) {
        await _repository.unlikePost(widget.post.id);
        setState(() {
          _hasLiked = false;
          _likeCount--;
        });
      } else {
        await _repository.likePost(widget.post.id);
        setState(() {
          _hasLiked = true;
          _likeCount++;
        });
      }
      widget.onLikeChanged?.call();
    } catch (e) {
      // Revert on error
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
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

    if (confirm == true) {
      try {
        await _repository.deletePost(widget.post.id);
        widget.onPostDeleted?.call();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
        }
      }
    }
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: widget.post.content);
    final isDark = widget.isDark;

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Edit Post',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Edit your post...',
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD66B),
              foregroundColor: Colors.black87,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null &&
        newContent.isNotEmpty &&
        newContent != widget.post.content) {
      try {
        await _repository.updatePost(widget.post.id, content: newContent);
        widget.onLikeChanged?.call(); // Refresh to show updated content
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final post = widget.post;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row with role badge
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                backgroundImage: post.authorAvatarUrl != null
                    ? NetworkImage(post.authorAvatarUrl!)
                    : null,
                child: post.authorAvatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: isDark ? Colors.white38 : Colors.black26,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Role badge (only for staff, managers, owners)
                        if (post.authorRole != AuthorRole.user) ...[
                          const SizedBox(width: 6),
                          _RoleBadge(role: post.authorRole),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isOwnPost)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _editPost();
                    if (value == 'delete') _deletePost();
                  },
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
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
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.more_horiz,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          // Media (photo or video)
          if (post.mediaUrl != null || post.photoUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.mediaType == 'video'
                  ? _VideoThumbnail(url: post.mediaUrl!, isDark: isDark)
                  : Image.network(
                      post.mediaUrl ?? post.photoUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ],
          // Poll (if exists)
          if (post.poll != null) ...[
            const SizedBox(height: 12),
            _PollWidget(
              poll: post.poll!,
              isDark: isDark,
              onVote: (optionIndex) async {
                try {
                  if (post.poll!.userVotes.contains(optionIndex)) {
                    await _repository.unvotePoll(post.poll!.id, optionIndex);
                  } else {
                    await _repository.votePoll(post.poll!.id, optionIndex);
                  }
                  widget.onLikeChanged?.call(); // Refresh to show updated votes
                } catch (e) {
                  // Handle error
                }
              },
            ),
          ],
          // Like and comment buttons
          const SizedBox(height: 12),
          Row(
            children: [
              // Like button
              _SocialButton(
                icon: _hasLiked ? Icons.favorite : Icons.favorite_border,
                label: _likeCount > 0 ? '$_likeCount' : 'Like',
                isActive: _hasLiked,
                isDark: isDark,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 16),
              // Comment button
              _SocialButton(
                icon: Icons.chat_bubble_outline,
                label: post.commentCount > 0
                    ? '${post.commentCount}'
                    : 'Comment',
                isActive: false,
                isDark: isDark,
                onTap: widget.onCommentTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Role badge widget
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final AuthorRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: role.badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: role.badgeColor,
        ),
      ),
    );
  }
}

/// Social action button (like, comment)
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFFEF4444) // Red for liked
        : (isDark ? Colors.white54 : Colors.black45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Video thumbnail placeholder
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.url, required this.isDark});

  final String url;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

/// Poll widget for displaying and voting on polls
class _PollWidget extends StatelessWidget {
  const _PollWidget({
    required this.poll,
    required this.isDark,
    required this.onVote,
  });

  final FeedPoll poll;
  final bool isDark;
  final Function(int) onVote;

  @override
  Widget build(BuildContext context) {
    final hasVoted = poll.userVotes.isNotEmpty;
    final totalVotes = poll.totalVotes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...poll.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = poll.userVotes.contains(index);
            final percentage = totalVotes > 0
                ? (option.voteCount / totalVotes * 100).round()
                : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: poll.isClosed ? null : () => onVote(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD66B).withValues(alpha: 0.2)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD66B)
                          : (isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasVoted || poll.isClosed) ...[
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${option.voteCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                      ],
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFFFFD66B),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          // Total votes
          Text(
            '$totalVotes vote${totalVotes == 1 ? '' : 's'}${poll.isClosed ? ' • Poll closed' : ''}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

/// Comments bottom sheet for viewing and adding comments
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.postId, required this.isDark});

  final String postId;
  final bool isDark;

  static Future<void> show(BuildContext context, String postId) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: postId, isDark: isDark),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _repository = FeedRepository();
  final _commentController = TextEditingController();
  List<FeedComment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  FeedComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _repository.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setReplyingTo(FeedComment? comment) {
    setState(() => _replyingTo = comment);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await _repository.addComment(
        widget.postId,
        text,
        parentCommentId: _replyingTo?.id,
      );
      if (mounted) {
        _commentController.clear();
        _replyingTo = null;
        _isSubmitting = false;
        await _loadComments();
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  int _countAllComments(List<FeedComment> comments) {
    int count = comments.length;
    for (final c in comments) {
      count += _countAllComments(c.replies);
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoading)
                  Text(
                    '(${_countAllComments(_comments)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                const Spacer(),
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
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _CommentThread(
                        comment: comment,
                        isDark: isDark,
                        depth: 0,
                        onReply: _setReplyingTo,
                        onDelete: () async {
                          try {
                            await _repository.deleteComment(comment.id);
                            if (mounted) await _loadComments();
                          } catch (e) {
                            // Handle error
                          }
                        },
                      );
                    },
                  ),
          ),
          // Reply indicator
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.authorName ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _setReplyingTo(null),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          // Comment input
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.grey[50],
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyingTo != null
                          ? 'Write a reply...'
                          : 'Write a comment...',
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: const Color(0xFFFFD66B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recursive comment thread widget for tree view
class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    required this.isDark,
    required this.depth,
    required this.onReply,
    required this.onDelete,
  });

  final FeedComment comment;
  final bool isDark;
  final int depth;
  final void Function(FeedComment) onReply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentTile(
          comment: comment,
          isDark: isDark,
          depth: depth,
          onReply: () => onReply(comment),
          onDelete: onDelete,
        ),
        // Render nested replies with indentation
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: comment.replies.map((reply) {
                return _CommentThread(
                  comment: reply,
                  isDark: isDark,
                  depth: depth + 1,
                  onReply: onReply,
                  onDelete: () async {
                    // Delete handled by parent reload
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// Individual comment tile with like functionality
class _CommentTile extends StatefulWidget {
  const _CommentTile({
    required this.comment,
    required this.isDark,
    required this.onDelete,
    this.depth = 0,
    this.onReply,
  });

  final FeedComment comment;
  final bool isDark;
  final VoidCallback onDelete;
  final int depth;
  final VoidCallback? onReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  final _repository = FeedRepository();
  late bool _hasLiked;
  late int _likeCount;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _hasLiked = widget.comment.hasLiked;
    _likeCount = widget.comment.likeCount;
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);

    try {
      if (_hasLiked) {
        await _repository.unlikeComment(widget.comment.id);
        setState(() {
          _hasLiked = false;
          _likeCount--;
        });
      } else {
        await _repository.likeComment(widget.comment.id);
        setState(() {
          _hasLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      // Revert on error
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final comment = widget.comment;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnComment = comment.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
            backgroundImage: comment.authorAvatarUrl != null
                ? NetworkImage(comment.authorAvatarUrl!)
                : null,
            child: comment.authorAvatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black26,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (comment.authorRole != AuthorRole.user) ...[
                      const SizedBox(width: 6),
                      _RoleBadge(role: comment.authorRole),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.3,
                  ),
                ),
                // Like and Reply buttons row
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _hasLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _hasLiked
                                ? Colors.red
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          if (_likeCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$_likeCount',
                              style: TextStyle(
                                fontSize: 12,
                                color: _hasLiked
                                    ? Colors.red
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: widget.onReply,
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isOwnComment)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') widget.onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to share something with your yard!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
