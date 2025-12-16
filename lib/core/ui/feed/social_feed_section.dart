import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/feed/data/feed_repository.dart';
import 'comments_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER - Simple header with icon and title for feed sections
// ─────────────────────────────────────────────────────────────────────────────

/// Section header with icon and title.
class FeedSectionHeader extends StatelessWidget {
  const FeedSectionHeader({super.key, required this.title, required this.icon});

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
        const FeedSectionHeader(
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

// ─────────────────────────────────────────────────────────────────────────────
// FEED POST CARD
// ─────────────────────────────────────────────────────────────────────────────

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
                          RoleBadge(role: post.authorRole),
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

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS - Used by multiple feed components
// ─────────────────────────────────────────────────────────────────────────────

/// Role badge widget - exported for use by announcements
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

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
