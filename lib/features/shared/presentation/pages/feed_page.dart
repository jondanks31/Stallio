import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/feed_widgets.dart';
import '../../../feed/data/feed_repository.dart';
import '../../../people/data/people_repository.dart';

/// Shared Feed page showing announcements and social feed.
/// Used by both Owner and User dashboards.
///
/// For Users: This is their "Home" page with welcome header.
/// For Owners: This is the "Feed" tab (welcome header is on Dashboard).
class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.yardId,
    this.showWelcomeHeader = false,
  });

  final String yardId;

  /// Whether to show the welcome header (greeting + weather).
  /// - true: For User's Home page
  /// - false: For Owner's Feed tab (they see welcome on Dashboard)
  final bool showWelcomeHeader;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _feedRepository = FeedRepository();
  YardRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = YardRole.fromString(profile['role'] as String? ?? 'user');
        });
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  bool get _canPost {
    // Owners and managers can post
    return _userRole == YardRole.owner || _userRole == YardRole.manager;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh in child widgets would require keys or state management
            // For now, rebuild by pushing same route
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              // Welcome header (optional - for User's Home)
              if (widget.showWelcomeHeader)
                const SliverToBoxAdapter(
                  child: WelcomeHeader(subtitle: 'Welcome to your yard'),
                ),

              // Announcements section
              SliverToBoxAdapter(
                child: AnnouncementsSection(yardId: widget.yardId),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Social feed section
              SliverToBoxAdapter(
                child: SocialFeedSection(yardId: widget.yardId),
              ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        // FAB for creating posts (only for owners/managers)
        if (_canPost)
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () => _showCreatePostDialog(context),
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    bool isPinned = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Create Post',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'What would you like to share?',
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isPinned,
                          onChanged: (v) =>
                              setDialogState(() => isPinned = v ?? false),
                          activeColor: const Color(0xFFFFD66B),
                        ),
                        Text(
                          'Pin as announcement',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    try {
                      await _feedRepository.createPost(
                        yardId: widget.yardId,
                        content: controller.text.trim(),
                        isPinned: isPinned,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating post: $e')),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      // Refresh the page to show new post
      setState(() {});
    }
  }
}
