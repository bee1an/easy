import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy/provider/follow_provider.dart';
import 'package:easy/service/follow_service.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';
import 'package:easy/core/widget/glassmorphism_card.dart';
import 'package:easy/core/widget/empty_state.dart';
import 'package:intl/intl.dart';

/// Follow Friends Page
///
/// Contains:
/// - Search users by email
/// - Mutual follows list
/// - Follow/unfollow actions
class FollowFriendsPage extends StatefulWidget {
  const FollowFriendsPage({super.key});

  @override
  State<FollowFriendsPage> createState() => _FollowFriendsPageState();
}

class _FollowFriendsPageState extends State<FollowFriendsPage> {
  final _searchController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // Debounce timer for search
  Timer? _debounceTimer;
  // Request sequence number to handle concurrent searches
  int _searchSequence = 0;

  @override
  void initState() {
    super.initState();
    // Load mutual follows on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowProvider>().loadMutualFollows();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchError = null;
        });
      }
      return;
    }

    // Debounce 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    final currentSequence = ++_searchSequence;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await context.read<FollowProvider>().searchUsers(query);
      // Only update if this is still the latest request
      if (mounted && currentSequence == _searchSequence) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted && currentSequence == _searchSequence) {
        setState(() {
          _searchError = '搜索失败';
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('关注好友'),
      ),
      body: Consumer<FollowProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索用户邮箱...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.dividerColor(context),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: _searchController.text.length >= 3
                    ? _buildSearchResults()
                    : _buildMutualFollowsList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchError != null) {
      return EmptyState.error(
        title: '搜索失败',
        description: _searchError!,
        onRetry: () => _performSearch(_searchController.text),
      );
    }

    if (_searchResults.isEmpty) {
      return EmptyState.noResults(
        description: '未找到匹配 "${_searchController.text}" 的用户',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchResultTile(
          user: user,
          onFollowChanged: () => _performSearch(_searchController.text),
        );
      },
    );
  }

  Widget _buildMutualFollowsList(FollowProvider provider) {
    if (provider.isLoading && provider.mutualFollows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.mutualFollows.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline_rounded,
        title: '暂无互关好友',
        description: '搜索并关注好友，当对方也关注你后即可查看彼此的健康数据',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadMutualFollows,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.mutualFollows.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                '互关好友 (${provider.mutualFollows.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textMutedColor(context),
                ),
              ),
            );
          }

          final friend = provider.mutualFollows[index - 1];
          return _MutualFollowTile(friend: friend);
        },
      ),
    );
  }
}

class _UserSearchResultTile extends StatefulWidget {
  final UserSearchResult user;
  final VoidCallback onFollowChanged;

  const _UserSearchResultTile({
    required this.user,
    required this.onFollowChanged,
  });

  @override
  State<_UserSearchResultTile> createState() => _UserSearchResultTileState();
}

class _UserSearchResultTileState extends State<_UserSearchResultTile> {
  bool _isLoading = false;

  Future<void> _toggleFollow() async {
    if (!mounted) return;

    final isUnfollow =
        widget.user.followStatus == FollowStatusType.following ||
        widget.user.followStatus == FollowStatusType.mutual;

    // Show confirmation dialog for unfollow
    if (isUnfollow) {
      final confirmed = await _showUnfollowConfirmDialog();
      if (!confirmed || !mounted) return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<FollowProvider>();
    bool success;
    String actionName;

    if (isUnfollow) {
      success = await provider.unfollowUser(widget.user.userId);
      actionName = '取消关注';
    } else {
      success = await provider.followUser(widget.user.userId);
      actionName = '关注';
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$actionName成功'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onFollowChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? '$actionName失败'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.clearError();
    }
  }

  Future<bool> _showUnfollowConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('取消关注'),
            content: Text(
              '取消关注 ${widget.user.email.split('@').first} 后，\n'
              '• 互关关系将解除\n'
              '• 无法查看对方数据\n'
              '• 对方也无法查看你的数据',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('再想想'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('确认取消'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final actionText = _getActionText();
    final isFollowing =
        widget.user.followStatus == FollowStatusType.following ||
        widget.user.followStatus == FollowStatusType.mutual;

    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundOpacity: 0.8,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              widget.user.email.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.email,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action button
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: _toggleFollow,
              style: TextButton.styleFrom(
                foregroundColor: isFollowing
                    ? AppTheme.error
                    : AppTheme.primary,
              ),
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.user.followStatus) {
      case FollowStatusType.mutual:
        return AppTheme.success;
      case FollowStatusType.following:
        return AppTheme.primary;
      case FollowStatusType.follower:
        return AppTheme.warning;
      case FollowStatusType.none:
        return AppTheme.textMuted;
    }
  }

  String _getStatusText() {
    switch (widget.user.followStatus) {
      case FollowStatusType.mutual:
        return '互相关注';
      case FollowStatusType.following:
        return '已关注';
      case FollowStatusType.follower:
        return 'TA关注了你';
      case FollowStatusType.none:
        return '未关注';
    }
  }

  String _getActionText() {
    switch (widget.user.followStatus) {
      case FollowStatusType.mutual:
      case FollowStatusType.following:
        return '取消关注';
      case FollowStatusType.follower:
        return '回关';
      case FollowStatusType.none:
        return '关注';
    }
  }
}

class _MutualFollowTile extends StatefulWidget {
  final MutualFollow friend;

  const _MutualFollowTile({required this.friend});

  @override
  State<_MutualFollowTile> createState() => _MutualFollowTileState();
}

class _MutualFollowTileState extends State<_MutualFollowTile> {
  bool _isLoading = false;

  Future<void> _unfollowFriend() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消关注'),
        content: Text(
          '取消关注 ${widget.friend.email.split('@').first} 后，\n'
          '• 互关关系将解除\n'
          '• 无法查看对方数据\n'
          '• 对方也无法查看你的数据',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('再想想'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    final provider = context.read<FollowProvider>();
    final success = await provider.unfollowUser(widget.friend.userId);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已取消关注'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? '取消关注失败'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.clearError();
    }
  }

  void _viewFriendStats() {
    AppRouter.push(
      context,
      AppRouter.stats,
      arguments: {
        'userId': widget.friend.userId,
        'userDisplayName': widget.friend.email.split('@').first,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundOpacity: 0.8,
      onTap: _viewFriendStats,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              widget.friend.email.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.email.split('@').first,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '互关于 ${DateFormat('yyyy/M/d').format(widget.friend.mutualSince)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMutedColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Unfollow button
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _unfollowFriend,
              icon: const Icon(Icons.person_remove_rounded),
              color: AppTheme.error.withValues(alpha: 0.7),
              tooltip: '取消关注',
              visualDensity: VisualDensity.compact,
            ),

          const SizedBox(width: 4),

          // View stats indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_rounded, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  '查看统计',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
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
