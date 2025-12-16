import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Author role for display badges
enum AuthorRole {
  owner,
  manager,
  staff,
  user;

  String get displayName {
    switch (this) {
      case AuthorRole.owner:
        return 'Owner';
      case AuthorRole.manager:
        return 'Manager';
      case AuthorRole.staff:
        return 'Staff';
      case AuthorRole.user:
        return 'Member';
    }
  }

  Color get badgeColor {
    switch (this) {
      case AuthorRole.owner:
        return const Color(0xFFFFD66B); // Yellow
      case AuthorRole.manager:
        return const Color(0xFF3B82F6); // Blue
      case AuthorRole.staff:
        return const Color(0xFF10B981); // Green
      case AuthorRole.user:
        return const Color(0xFF6B7280); // Grey
    }
  }

  static AuthorRole fromString(String? role) {
    switch (role) {
      case 'owner':
        return AuthorRole.owner;
      case 'manager':
        return AuthorRole.manager;
      case 'staff':
        return AuthorRole.staff;
      default:
        return AuthorRole.user;
    }
  }
}

/// Model for a poll option
class PollOption {
  final String text;
  final int voteCount;

  PollOption({required this.text, this.voteCount = 0});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      text: json['text'] as String,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'vote_count': voteCount};
}

/// Model for a poll attached to a post
class FeedPoll {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool allowMultiple;
  final DateTime? closesAt;
  final Set<int> userVotes; // Indices the current user voted for

  FeedPoll({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultiple = false,
    this.closesAt,
    this.userVotes = const {},
  });

  bool get isClosed => closesAt != null && DateTime.now().isAfter(closesAt!);
  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.voteCount);

  factory FeedPoll.fromJson(Map<String, dynamic> json, {Set<int>? userVotes}) {
    final optionsList = json['options'] as List? ?? [];
    return FeedPoll(
      id: json['id'] as String,
      question: json['question'] as String,
      options: optionsList
          .map((o) => PollOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      allowMultiple: json['allow_multiple'] as bool? ?? false,
      closesAt: json['closes_at'] != null
          ? DateTime.parse(json['closes_at'] as String)
          : null,
      userVotes: userVotes ?? {},
    );
  }
}

/// Model for a comment on a post (supports threading via parentId)
class FeedComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final AuthorRole authorRole;
  final int likeCount;
  final bool hasLiked;
  final String? parentId;
  final List<FeedComment> replies;

  FeedComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.authorAvatarUrl,
    this.authorRole = AuthorRole.user,
    this.likeCount = 0,
    this.hasLiked = false,
    this.parentId,
    this.replies = const [],
  });

  factory FeedComment.fromJson(
    Map<String, dynamic> json, {
    int likeCount = 0,
    bool hasLiked = false,
    List<FeedComment> replies = const [],
  }) {
    final author = json['author'] as Map<String, dynamic>?;
    return FeedComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: author?['full_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
      authorRole: AuthorRole.fromString(author?['role'] as String?),
      likeCount: likeCount,
      hasLiked: hasLiked,
      parentId: json['parent_comment_id'] as String?,
      replies: replies,
    );
  }

  FeedComment copyWith({List<FeedComment>? replies}) {
    return FeedComment(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      createdAt: createdAt,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      authorRole: authorRole,
      likeCount: likeCount,
      hasLiked: hasLiked,
      parentId: parentId,
      replies: replies ?? this.replies,
    );
  }

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

/// Model for a feed post
class FeedPost {
  final String id;
  final String yardId;
  final String authorId;
  final String content;
  final String? photoUrl;
  final String? mediaUrl;
  final String? mediaType; // 'image' or 'video'
  final bool isPinned;
  final DateTime? announcementExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? authorName;
  final String? authorAvatarUrl;
  final AuthorRole authorRole;

  // Social features
  final int likeCount;
  final int commentCount;
  final bool hasLiked;
  final FeedPoll? poll;

  FeedPost({
    required this.id,
    required this.yardId,
    required this.authorId,
    required this.content,
    this.photoUrl,
    this.mediaUrl,
    this.mediaType,
    this.isPinned = false,
    this.announcementExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.authorRole = AuthorRole.user,
    this.likeCount = 0,
    this.commentCount = 0,
    this.hasLiked = false,
    this.poll,
  });

  /// Check if announcement is still active (not expired)
  bool get isAnnouncementActive {
    if (!isPinned) return false;
    if (announcementExpiresAt == null) return true; // No expiry = always active
    return DateTime.now().isBefore(announcementExpiresAt!);
  }

  factory FeedPost.fromJson(
    Map<String, dynamic> json, {
    int likeCount = 0,
    int commentCount = 0,
    bool hasLiked = false,
    FeedPoll? poll,
  }) {
    final author = json['author'] as Map<String, dynamic>?;

    return FeedPost(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      photoUrl: json['photo_url'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      announcementExpiresAt: json['announcement_expires_at'] != null
          ? DateTime.parse(json['announcement_expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: author?['full_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
      authorRole: AuthorRole.fromString(
        json['author_role'] as String? ?? author?['role'] as String?,
      ),
      likeCount: likeCount,
      commentCount: commentCount,
      hasLiked: hasLiked,
      poll: poll,
    );
  }

  FeedPost copyWith({
    int? likeCount,
    int? commentCount,
    bool? hasLiked,
    FeedPoll? poll,
  }) {
    return FeedPost(
      id: id,
      yardId: yardId,
      authorId: authorId,
      content: content,
      photoUrl: photoUrl,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      isPinned: isPinned,
      announcementExpiresAt: announcementExpiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      authorRole: authorRole,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      hasLiked: hasLiked ?? this.hasLiked,
      poll: poll ?? this.poll,
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

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get pinned posts (announcements) for a yard - only active ones
  Future<List<FeedPost>> getAnnouncements(
    String yardId, {
    int limit = 3,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final response = await _supabase
        .from('feed_posts')
        .select(
          '*, author:profiles!feed_posts_author_id_profiles_fkey(full_name, avatar_url, role)',
        )
        .eq('yard_id', yardId)
        .eq('is_pinned', true)
        .or('announcement_expires_at.is.null,announcement_expires_at.gt.$now')
        .order('created_at', ascending: false)
        .limit(limit);

    final posts = await _enrichPostsWithSocialData(response as List);
    return posts;
  }

  /// Get feed posts for a yard (excluding pinned)
  Future<List<FeedPost>> getFeedPosts(
    String yardId, {
    int limit = 20,
    DateTime? before,
  }) async {
    var query = _supabase
        .from('feed_posts')
        .select(
          '*, author:profiles!feed_posts_author_id_profiles_fkey(full_name, avatar_url, role)',
        )
        .eq('yard_id', yardId)
        .eq('is_pinned', false);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    final posts = await _enrichPostsWithSocialData(response as List);
    return posts;
  }

  /// Enrich posts with like counts, comment counts, and user's like status
  Future<List<FeedPost>> _enrichPostsWithSocialData(
    List<dynamic> rawPosts,
  ) async {
    if (rawPosts.isEmpty) return [];

    final postIds = rawPosts.map((p) => p['id'] as String).toList();
    final userId = _currentUserId;

    // Get like counts
    final likeCounts = await _supabase
        .from('feed_post_likes')
        .select('post_id')
        .inFilter('post_id', postIds);

    // Get comment counts
    final commentCounts = await _supabase
        .from('feed_post_comments')
        .select('post_id')
        .inFilter('post_id', postIds);

    // Get user's likes
    Set<String> userLikedPosts = {};
    if (userId != null) {
      final userLikes = await _supabase
          .from('feed_post_likes')
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);
      userLikedPosts = (userLikes as List)
          .map((l) => l['post_id'] as String)
          .toSet();
    }

    // Count likes per post
    final likeCountMap = <String, int>{};
    for (final like in likeCounts as List) {
      final postId = like['post_id'] as String;
      likeCountMap[postId] = (likeCountMap[postId] ?? 0) + 1;
    }

    // Count comments per post
    final commentCountMap = <String, int>{};
    for (final comment in commentCounts as List) {
      final postId = comment['post_id'] as String;
      commentCountMap[postId] = (commentCountMap[postId] ?? 0) + 1;
    }

    // Get polls for posts that have them
    final pollIds = rawPosts
        .where((p) => p['poll_id'] != null)
        .map((p) => p['poll_id'] as String)
        .toList();

    Map<String, FeedPoll> pollMap = {};
    if (pollIds.isNotEmpty) {
      final polls = await _supabase
          .from('feed_polls')
          .select()
          .inFilter('id', pollIds);

      // Get user's votes for these polls
      Map<String, Set<int>> userVotesMap = {};
      if (userId != null) {
        final userVotes = await _supabase
            .from('feed_poll_votes')
            .select('poll_id, option_index')
            .eq('user_id', userId)
            .inFilter('poll_id', pollIds);

        for (final vote in userVotes as List) {
          final pollId = vote['poll_id'] as String;
          userVotesMap.putIfAbsent(pollId, () => {});
          userVotesMap[pollId]!.add(vote['option_index'] as int);
        }
      }

      // Get vote counts per option
      final allVotes = await _supabase
          .from('feed_poll_votes')
          .select('poll_id, option_index')
          .inFilter('poll_id', pollIds);

      final voteCountsPerPoll = <String, Map<int, int>>{};
      for (final vote in allVotes as List) {
        final pollId = vote['poll_id'] as String;
        final optionIndex = vote['option_index'] as int;
        voteCountsPerPoll.putIfAbsent(pollId, () => {});
        voteCountsPerPoll[pollId]![optionIndex] =
            (voteCountsPerPoll[pollId]![optionIndex] ?? 0) + 1;
      }

      for (final pollJson in polls as List) {
        final pollId = pollJson['id'] as String;
        final optionsList = pollJson['options'] as List? ?? [];

        // Update options with vote counts
        final updatedOptions = <Map<String, dynamic>>[];
        for (int i = 0; i < optionsList.length; i++) {
          final opt = optionsList[i] as Map<String, dynamic>;
          updatedOptions.add({
            'text': opt['text'],
            'vote_count': voteCountsPerPoll[pollId]?[i] ?? 0,
          });
        }

        pollMap[pollId] = FeedPoll.fromJson({
          ...pollJson,
          'options': updatedOptions,
        }, userVotes: userVotesMap[pollId] ?? {});
      }
    }

    return rawPosts.map((json) {
      final postId = json['id'] as String;
      final pollId = json['poll_id'] as String?;
      return FeedPost.fromJson(
        json,
        likeCount: likeCountMap[postId] ?? 0,
        commentCount: commentCountMap[postId] ?? 0,
        hasLiked: userLikedPosts.contains(postId),
        poll: pollId != null ? pollMap[pollId] : null,
      );
    }).toList();
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
    String? mediaUrl,
    String? mediaType,
    bool isPinned = false,
    int? announcementHours, // How many hours the announcement should be pinned
    String? pollId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Get user's role for the post
    final profile = await _supabase
        .from('profiles')
        .select('role')
        .eq('user_id', userId)
        .single();
    final authorRole = profile['role'] as String?;

    final id = _uuid.v4();

    DateTime? announcementExpiresAt;
    if (isPinned && announcementHours != null) {
      announcementExpiresAt = DateTime.now().add(
        Duration(hours: announcementHours),
      );
    }

    final response = await _supabase
        .from('feed_posts')
        .insert({
          'id': id,
          'yard_id': yardId,
          'author_id': userId,
          'content': content,
          'photo_url': photoUrl,
          'media_url': mediaUrl,
          'media_type': mediaType,
          'is_pinned': isPinned,
          'author_role': authorRole,
          'announcement_expires_at': announcementExpiresAt
              ?.toUtc()
              .toIso8601String(),
          'poll_id': pollId,
        })
        .select('''
          *,
          author:profiles!feed_posts_author_id_profiles_fkey(full_name, avatar_url, role)
        ''')
        .single();

    return FeedPost.fromJson(response);
  }

  /// Create a poll and return its ID
  Future<String> createPoll({
    required String question,
    required List<String> options,
    bool allowMultiple = false,
    DateTime? closesAt,
  }) async {
    final id = _uuid.v4();

    await _supabase.from('feed_polls').insert({
      'id': id,
      'question': question,
      'options': options
          .map((text) => {'text': text, 'vote_count': 0})
          .toList(),
      'allow_multiple': allowMultiple,
      'closes_at': closesAt?.toUtc().toIso8601String(),
    });

    return id;
  }

  /// Vote on a poll option
  Future<void> votePoll(String pollId, int optionIndex) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('feed_poll_votes').insert({
      'poll_id': pollId,
      'user_id': userId,
      'option_index': optionIndex,
    });
  }

  /// Remove vote from a poll option
  Future<void> unvotePoll(String pollId, int optionIndex) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('feed_poll_votes')
        .delete()
        .eq('poll_id', pollId)
        .eq('user_id', userId)
        .eq('option_index', optionIndex);
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('feed_post_likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('feed_post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  /// Get comments for a post with like data, organized as a tree
  Future<List<FeedComment>> getComments(String postId) async {
    final userId = _currentUserId;

    final response = await _supabase
        .from('feed_post_comments')
        .select('''
          *,
          author:profiles!feed_post_comments_user_id_profiles_fkey(full_name, avatar_url, role)
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final comments = response as List;
    if (comments.isEmpty) return [];

    // Get like counts and user's likes
    final commentIds = comments.map((c) => c['id'] as String).toList();

    final likeCounts = await _supabase
        .from('feed_comment_likes')
        .select('comment_id')
        .inFilter('comment_id', commentIds);

    Set<String> userLikedComments = {};
    if (userId != null) {
      final userLikes = await _supabase
          .from('feed_comment_likes')
          .select('comment_id')
          .eq('user_id', userId)
          .inFilter('comment_id', commentIds);
      userLikedComments = (userLikes as List)
          .map((l) => l['comment_id'] as String)
          .toSet();
    }

    // Count likes per comment
    final likeCountMap = <String, int>{};
    for (final like in likeCounts as List) {
      final commentId = like['comment_id'] as String;
      likeCountMap[commentId] = (likeCountMap[commentId] ?? 0) + 1;
    }

    // Parse all comments
    final allComments = comments.map((json) {
      final id = json['id'] as String;
      return FeedComment.fromJson(
        json,
        likeCount: likeCountMap[id] ?? 0,
        hasLiked: userLikedComments.contains(id),
      );
    }).toList();

    // Build tree structure using recursive helper
    final commentMap = <String, FeedComment>{};
    for (final comment in allComments) {
      commentMap[comment.id] = comment;
    }

    // Group comments by parent
    final childrenMap = <String?, List<FeedComment>>{};
    for (final comment in allComments) {
      childrenMap.putIfAbsent(comment.parentId, () => []).add(comment);
    }

    // Recursively build tree
    FeedComment buildTree(FeedComment comment) {
      final children = childrenMap[comment.id] ?? [];
      if (children.isEmpty) return comment;
      return comment.copyWith(replies: children.map(buildTree).toList());
    }

    // Get root comments and build their trees
    final rootComments = childrenMap[null] ?? [];
    return rootComments.map(buildTree).toList();
  }

  /// Add a comment to a post (optionally as a reply)
  Future<FeedComment> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final data = {'post_id': postId, 'user_id': userId, 'content': content};
    if (parentCommentId != null) {
      data['parent_comment_id'] = parentCommentId;
    }

    final response = await _supabase
        .from('feed_post_comments')
        .insert(data)
        .select('''
          *,
          author:profiles!feed_post_comments_user_id_profiles_fkey(full_name, avatar_url, role)
        ''')
        .single();

    return FeedComment.fromJson(response);
  }

  /// Like a comment
  Future<void> likeComment(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('feed_comment_likes').insert({
      'comment_id': commentId,
      'user_id': userId,
    });
  }

  /// Unlike a comment
  Future<void> unlikeComment(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('feed_comment_likes')
        .delete()
        .eq('comment_id', commentId)
        .eq('user_id', userId);
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    await _supabase.from('feed_post_comments').delete().eq('id', commentId);
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

  /// Upload media for a post and return the URL (File-based, for mobile)
  Future<String> uploadMedia(String yardId, File file, String fileName) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final path =
        '$yardId/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage
        .from('feed-media')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('feed-media').getPublicUrl(path);
  }

  /// Upload media for a post and return the URL (Bytes-based, for web)
  Future<String> uploadMediaBytes(
    String yardId,
    Uint8List bytes,
    String fileName,
  ) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final path =
        '$yardId/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage
        .from('feed-media')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('feed-media').getPublicUrl(path);
  }
}
