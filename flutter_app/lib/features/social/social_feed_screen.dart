import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/app_bottom_nav.dart';

/// Social feed — see what friends liked and saved.
class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  List<Map<String, dynamic>> _feed = [];
  List<Map<String, dynamic>> _following = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final feedRes = await api.get('/social/feed');
      final followRes = await api.get('/social/following');

      // Check in for streak
      api.post('/social/streak/checkin', body: {}).ignore();

      setState(() {
        _feed = List<Map<String, dynamic>>.from(feedRes['feed'] ?? []);
        _following = List<Map<String, dynamic>>.from(followRes['following'] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.stoicism, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Social',
                    style: AppTypography.displaySmall.copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                  // Following count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.stoicism.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_following.length} following',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.stoicism,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add friend button
                  GestureDetector(
                    onTap: _showAddFriendDialog,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.person_add_outlined, color: AppColors.stoicism, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.stoicism))
                  : _error != null
                      ? Center(child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)))
                      : _feed.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppColors.stoicism,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: _feed.length,
                                itemBuilder: (context, i) => _FeedItem(item: _feed[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: -1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Follow friends to see their activity',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'See what quotes they like and save',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Find a Friend', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by display name...',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final query = controller.text.trim();
                if (query.isEmpty) return;
                try {
                  final api = ref.read(apiClientProvider);
                  final res = await api.get('/shares/search-user?q=$query');
                  final users = List<Map<String, dynamic>>.from(res['users'] ?? []);
                  if (users.isEmpty) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('No users found')),
                      );
                    }
                    return;
                  }
                  // Follow the first match
                  final userId = users.first['device_id'];
                  await api.post('/social/follow', body: {'user_id': userId});
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Search & Follow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final user = item['user'] ?? 'Someone';
    final action = item['action'] ?? 'liked';
    final quote = item['quote'] as Map<String, dynamic>? ?? {};
    final text = quote['text'] ?? '';
    final author = quote['author'] ?? '';
    final category = (quote['category'] ?? '').toString();
    final timeAgo = _formatTimeAgo(item['at']);

    final actionIcon = action == 'vault'
        ? Icons.bookmark
        : action == 'share'
            ? Icons.send
            : Icons.favorite;
    final actionColor = action == 'vault'
        ? AppColors.vault
        : action == 'share'
            ? AppColors.stoicism
            : AppColors.like;
    final actionLabel = action == 'vault' ? 'saved' : action == 'share' ? 'shared' : 'liked';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User + action header
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: actionColor.withOpacity(0.15),
                child: Text(
                  user.toString().isNotEmpty ? user[0].toUpperCase() : '?',
                  style: AppTypography.caption.copyWith(color: actionColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: user,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' $actionLabel a quote',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(actionIcon, size: 14, color: actionColor),
              const SizedBox(width: 6),
              Text(timeAgo, style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),

          // Quote
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.categoryColorSubtle(category),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.categoryColor(category).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$text"',
                  style: AppTypography.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '— $author',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.categoryColor(category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}w';
    } catch (_) {
      return '';
    }
  }
}
