import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/feed/data/feed_repository.dart';
import 'comments_sheet.dart';
import 'social_feed_section.dart';

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
                            RoleBadge(role: post.authorRole),
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
