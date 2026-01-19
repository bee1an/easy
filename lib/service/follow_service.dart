import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy/core/config/supabase_config.dart';

/// Follow service for mutual follow feature
///
/// Handles:
/// - Following/unfollowing users
/// - Checking follow status
/// - Getting mutual follow list
/// - Searching users by email
class FollowService {
  static FollowService? _instance;
  static FollowService get instance => _instance ??= FollowService._();

  FollowService._();

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  bool get isAvailable => _client != null;

  String? get currentUserId => _client?.auth.currentUser?.id;

  /// Follow a user
  Future<FollowResult> followUser(String userId) async {
    if (_client == null || currentUserId == null) {
      return FollowResult.failure('未登录');
    }

    try {
      await _client!.from('follows').insert({
        'follower_id': currentUserId,
        'following_id': userId,
      });
      return FollowResult.success();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - already following
        return FollowResult.failure('已经关注了该用户');
      }
      return FollowResult.failure(e.message);
    } catch (e) {
      return FollowResult.failure('关注失败: $e');
    }
  }

  /// Unfollow a user
  Future<FollowResult> unfollowUser(String userId) async {
    if (_client == null || currentUserId == null) {
      return FollowResult.failure('未登录');
    }

    try {
      await _client!
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId!)
          .eq('following_id', userId);
      return FollowResult.success();
    } catch (e) {
      return FollowResult.failure('取消关注失败: $e');
    }
  }

  /// Get follow status between current user and another user
  Future<FollowStatus> getFollowStatus(String userId) async {
    if (_client == null || currentUserId == null) {
      return FollowStatus.unknown();
    }

    try {
      final response = await _client!.rpc(
        'get_follow_status',
        params: {'p_other_user_id': userId},
      );

      if (response is List && response.isNotEmpty) {
        final data = response[0] as Map<String, dynamic>;
        return FollowStatus(
          iFollowThem: data['i_follow_them'] as bool? ?? false,
          theyFollowMe: data['they_follow_me'] as bool? ?? false,
          isMutual: data['is_mutual'] as bool? ?? false,
        );
      }
      return FollowStatus.unknown();
    } catch (e) {
      debugPrint('FollowService: Failed to get follow status: $e');
      return FollowStatus.unknown();
    }
  }

  /// Get list of mutual follows
  Future<List<MutualFollow>> getMutualFollows() async {
    if (_client == null || currentUserId == null) {
      return [];
    }

    try {
      final response = await _client!.rpc(
        'get_mutual_follows',
        params: {'p_user_id': currentUserId},
      );

      if (response is List) {
        return response.map((data) {
          final map = data as Map<String, dynamic>;
          // Handle mutual_since: could be String, DateTime, or null
          DateTime mutualSince;
          final rawMutualSince = map['mutual_since'];
          if (rawMutualSince is DateTime) {
            mutualSince = rawMutualSince;
          } else if (rawMutualSince is String) {
            mutualSince = DateTime.tryParse(rawMutualSince) ?? DateTime.now();
          } else {
            mutualSince = DateTime.now();
          }
          return MutualFollow(
            userId: map['user_id'] as String,
            email: map['email'] as String,
            mutualSince: mutualSince,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('FollowService: Failed to get mutual follows: $e');
      return [];
    }
  }

  /// Search users by email
  Future<List<UserSearchResult>> searchUsersByEmail(String query) async {
    if (_client == null || currentUserId == null || query.length < 3) {
      return [];
    }

    try {
      final response = await _client!.rpc(
        'search_users_by_email',
        params: {'p_email_query': query},
      );

      if (response is List) {
        return response.map((data) {
          final map = data as Map<String, dynamic>;
          return UserSearchResult(
            userId: map['user_id'] as String,
            email: map['email'] as String,
            followStatus: _parseFollowStatusString(
              map['follow_status'] as String,
            ),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('FollowService: Failed to search users: $e');
      return [];
    }
  }

  FollowStatusType _parseFollowStatusString(String status) {
    switch (status) {
      case 'mutual':
        return FollowStatusType.mutual;
      case 'following':
        return FollowStatusType.following;
      case 'follower':
        return FollowStatusType.follower;
      default:
        return FollowStatusType.none;
    }
  }

  /// Check if current user has mutual follow with another user
  Future<bool> isMutualFollow(String userId) async {
    if (_client == null || currentUserId == null) {
      return false;
    }

    try {
      final response = await _client!.rpc(
        'is_mutual_follow',
        params: {'p_user_id': currentUserId, 'p_other_user_id': userId},
      );
      return response as bool? ?? false;
    } catch (e) {
      debugPrint('FollowService: Failed to check mutual follow: $e');
      return false;
    }
  }
}

/// Result of follow operations
class FollowResult {
  final bool success;
  final String? error;

  FollowResult._({required this.success, this.error});

  factory FollowResult.success() => FollowResult._(success: true);
  factory FollowResult.failure(String error) =>
      FollowResult._(success: false, error: error);
}

/// Follow status between two users
class FollowStatus {
  final bool iFollowThem;
  final bool theyFollowMe;
  final bool isMutual;

  FollowStatus({
    required this.iFollowThem,
    required this.theyFollowMe,
    required this.isMutual,
  });

  factory FollowStatus.unknown() =>
      FollowStatus(iFollowThem: false, theyFollowMe: false, isMutual: false);
}

/// Follow status types
enum FollowStatusType { none, following, follower, mutual }

/// Mutual follow data
class MutualFollow {
  final String userId;
  final String email;
  final DateTime mutualSince;

  MutualFollow({
    required this.userId,
    required this.email,
    required this.mutualSince,
  });
}

/// User search result
class UserSearchResult {
  final String userId;
  final String email;
  final FollowStatusType followStatus;

  UserSearchResult({
    required this.userId,
    required this.email,
    required this.followStatus,
  });
}
