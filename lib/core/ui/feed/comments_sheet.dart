import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/feed/data/feed_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMMENTS SHEET - Bottom sheet for viewing and adding comments
// ─────────────────────────────────────────────────────────────────────────────

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
                      _CommentRoleBadge(role: comment.authorRole),
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

/// Role badge widget for comments (local copy to avoid circular deps)
class _CommentRoleBadge extends StatelessWidget {
  const _CommentRoleBadge({required this.role});

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
