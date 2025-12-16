import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/feed_widgets.dart';
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
  final _feedKey = GlobalKey<_FeedContentState>();
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

  bool get _canCreateAnnouncement {
    return _userRole == YardRole.owner || _userRole == YardRole.manager;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _feedKey.currentState?.refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Welcome header (optional - for User's Home)
          if (widget.showWelcomeHeader)
            const SliverToBoxAdapter(
              child: WelcomeHeader(subtitle: 'Welcome to your yard'),
            ),

          // Feed content with create post card
          SliverToBoxAdapter(
            child: _FeedContent(
              key: _feedKey,
              yardId: widget.yardId,
              canCreateAnnouncement: _canCreateAnnouncement,
            ),
          ),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Feed content with create post card and posts list
class _FeedContent extends StatefulWidget {
  const _FeedContent({
    super.key,
    required this.yardId,
    required this.canCreateAnnouncement,
  });

  final String yardId;
  final bool canCreateAnnouncement;

  @override
  State<_FeedContent> createState() => _FeedContentState();
}

class _FeedContentState extends State<_FeedContent> {
  final _socialFeedKey = GlobalKey<SocialFeedSectionState>();

  void refresh() {
    _socialFeedKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Create post card - available to all users
        CreatePostCard(
          yardId: widget.yardId,
          canCreateAnnouncement: widget.canCreateAnnouncement,
          onPostCreated: refresh,
        ),
        const SizedBox(height: 24),
        // Announcements section (only shows when there are active announcements)
        AnnouncementsSection(yardId: widget.yardId),
        // Social feed section
        SocialFeedSection(key: _socialFeedKey, yardId: widget.yardId),
      ],
    );
  }
}
