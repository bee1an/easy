import 'package:flutter/foundation.dart';
import 'package:easy/service/follow_service.dart';

/// Follow state provider
///
/// Manages:
/// - Mutual follow list
/// - Current viewing user (self or friend)
/// - Follow/unfollow operations
/// - User search
class FollowProvider with ChangeNotifier {
  final FollowService _service = FollowService.instance;

  List<MutualFollow> _mutualFollows = [];
  bool _isLoading = false;
  String? _error;

  // Currently selected user for viewing data (null = self)
  String? _selectedUserId;
  String? _selectedUserEmail;

  /// List of mutual follows
  List<MutualFollow> get mutualFollows => _mutualFollows;

  /// Whether loading is in progress
  bool get isLoading => _isLoading;

  /// Last error message
  String? get error => _error;

  /// Currently selected user ID (null = viewing own data)
  String? get selectedUserId => _selectedUserId;

  /// Currently selected user email
  String? get selectedUserEmail => _selectedUserEmail;

  /// Whether viewing own data
  bool get isViewingSelf => _selectedUserId == null;

  /// Display name for current view
  String get currentViewLabel =>
      isViewingSelf ? '我的' : (_selectedUserEmail?.split('@').first ?? 'TA的');

  /// Load mutual follows list
  Future<void> loadMutualFollows() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mutualFollows = await _service.getMutualFollows();
    } catch (e) {
      _error = '加载好友列表失败';
      debugPrint('FollowProvider: Failed to load mutual follows: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Follow a user
  Future<bool> followUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.followUser(userId);

    _isLoading = false;
    if (!result.success) {
      _error = result.error;
    }
    notifyListeners();

    // Refresh mutual follows if successful
    if (result.success) {
      await loadMutualFollows();
    }

    return result.success;
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.unfollowUser(userId);

    _isLoading = false;
    if (!result.success) {
      _error = result.error;
    }
    notifyListeners();

    // Refresh mutual follows and reset view if needed
    if (result.success) {
      if (_selectedUserId == userId) {
        // If unfollowed the currently viewed user, switch back to self
        selectSelf();
      }
      await loadMutualFollows();
    }

    return result.success;
  }

  /// Get follow status for a user
  Future<FollowStatus> getFollowStatus(String userId) async {
    return await _service.getFollowStatus(userId);
  }

  /// Search users by email
  Future<List<UserSearchResult>> searchUsers(String query) async {
    if (query.length < 3) return [];
    return await _service.searchUsersByEmail(query);
  }

  /// Select a mutual follow to view their data
  void selectUser(String userId, String email) {
    _selectedUserId = userId;
    _selectedUserEmail = email;
    notifyListeners();
  }

  /// Switch back to viewing own data
  void selectSelf() {
    _selectedUserId = null;
    _selectedUserEmail = null;
    notifyListeners();
  }

  /// Toggle between self and a friend (for quick switch)
  void toggleView(MutualFollow friend) {
    if (_selectedUserId == friend.userId) {
      selectSelf();
    } else {
      selectUser(friend.userId, friend.email);
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if a specific user is currently selected
  bool isUserSelected(String userId) => _selectedUserId == userId;
}
