import 'package:flutter/material.dart';

import '../../../../core/ui/feed_widgets.dart';

/// Shared Feed page showing announcements and social feed.
/// Used by both Owner and User dashboards.
///
/// For Users: This is their "Home" page with welcome header.
/// For Owners: This is the "Feed" tab (welcome header is on Dashboard).
class FeedPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh feed data
      },
      child: CustomScrollView(
        slivers: [
          // Welcome header (optional - for User's Home)
          if (showWelcomeHeader)
            const SliverToBoxAdapter(
              child: WelcomeHeader(subtitle: 'Welcome to your yard'),
            ),

          // Announcements section
          SliverToBoxAdapter(child: AnnouncementsSection(yardId: yardId)),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Social feed section
          SliverToBoxAdapter(child: SocialFeedSection(yardId: yardId)),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
