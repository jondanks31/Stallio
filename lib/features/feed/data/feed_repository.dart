import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Model for a feed post
class FeedPost {
  final String id;
  final String yardId;
  final String authorId;
  final String content;
  final String? photoUrl;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? authorName;
  final String? authorAvatarUrl;

  FeedPost({
    required this.id,
    required this.yardId,
    required this.authorId,
    required this.content,
    this.photoUrl,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;

    return FeedPost(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      photoUrl: json['photo_url'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: author?['full_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
    );
  }

  /// Returns a relative time string (e.g., "Just now", "5m ago", "2h ago")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

/// Repository for feed/announcements
class FeedRepository {
  final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get pinned posts (announcements) for a yard
  Future<List<FeedPost>> getAnnouncements(
    String yardId, {
    int limit = 3,
  }) async {
    final response = await _supabase
        .from('feed_posts')
        .select('''
          *,
          author:profiles!feed_posts_author_id_fkey(full_name, avatar_url)
        ''')
        .eq('yard_id', yardId)
        .eq('is_pinned', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => FeedPost.fromJson(json)).toList();
  }

  /// Get feed posts for a yard (excluding pinned)
  Future<List<FeedPost>> getFeedPosts(
    String yardId, {
    int limit = 20,
    DateTime? before,
  }) async {
    var query = _supabase
        .from('feed_posts')
        .select('''
          *,
          author:profiles!feed_posts_author_id_fkey(full_name, avatar_url)
        ''')
        .eq('yard_id', yardId)
        .eq('is_pinned', false);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => FeedPost.fromJson(json)).toList();
  }

  /// Get all posts (both pinned and regular) for initial load
  Future<({List<FeedPost> announcements, List<FeedPost> posts})> getAll(
    String yardId, {
    int postsLimit = 20,
  }) async {
    final announcements = await getAnnouncements(yardId);
    final posts = await getFeedPosts(yardId, limit: postsLimit);
    return (announcements: announcements, posts: posts);
  }

  /// Create a new post
  Future<FeedPost> createPost({
    required String yardId,
    required String content,
    String? photoUrl,
    bool isPinned = false,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final id = _uuid.v4();

    final response = await _supabase
        .from('feed_posts')
        .insert({
          'id': id,
          'yard_id': yardId,
          'author_id': userId,
          'content': content,
          'photo_url': photoUrl,
          'is_pinned': isPinned,
        })
        .select('''
          *,
          author:profiles!feed_posts_author_id_fkey(full_name, avatar_url)
        ''')
        .single();

    return FeedPost.fromJson(response);
  }

  /// Update a post
  Future<void> updatePost(
    String postId, {
    String? content,
    bool? isPinned,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (content != null) updates['content'] = content;
    if (isPinned != null) updates['is_pinned'] = isPinned;

    await _supabase.from('feed_posts').update(updates).eq('id', postId);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _supabase.from('feed_posts').delete().eq('id', postId);
  }

  /// Pin/unpin a post
  Future<void> togglePin(String postId, bool isPinned) async {
    await updatePost(postId, isPinned: isPinned);
  }
}
