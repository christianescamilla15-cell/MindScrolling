import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/quote_model.dart';
import '../settings/settings_controller.dart';

/// Reusable feed widget for hidden modes (science, coding).
///
/// Fetches content filtered by contentType and subCategory from the backend.
/// Displays items in a vertically scrollable card layout.
class HiddenModeFeed extends ConsumerStatefulWidget {
  const HiddenModeFeed({
    super.key,
    required this.contentType,
    required this.subCategory,
    required this.accentColor,
  });

  final String contentType;
  final String subCategory;
  final Color accentColor;

  @override
  ConsumerState<HiddenModeFeed> createState() => _HiddenModeFeedState();
}

class _HiddenModeFeedState extends ConsumerState<HiddenModeFeed> {
  List<QuoteModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() { _loading = true; _error = null; });

    try {
      final api = ref.read(apiClientProvider);
      final lang = ref.read(settingsStateProvider).lang;

      // Use the insight/match endpoint with content type filter,
      // or fallback to a direct feed fetch for hidden mode content.
      // For now, we use a generic query approach.
      final response = await api.get('/quotes/feed', queryParams: {
        'lang': lang,
        'limit': '20',
        'content_type': widget.contentType,
        'sub_category': widget.subCategory,
      });

      final rawData = response['data'] as List? ?? [];
      final items = rawData
          .whereType<Map<String, dynamic>>()
          .map((q) => QuoteModel.fromJson(q))
          .toList();

      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          color: widget.accentColor,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              'Coming soon',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Science content is being curated.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadContent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.accentColor),
                ),
                child: Text(
                  'Retry',
                  style: AppTypography.labelSmall.copyWith(color: widget.accentColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: widget.accentColor, size: 40),
            const SizedBox(height: 12),
            Text(
              'Content coming soon',
              style: AppTypography.bodyMedium.copyWith(color: widget.accentColor),
            ),
            const SizedBox(height: 8),
            Text(
              'This branch is being prepared.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _ContentCard(
          item: item,
          accentColor: widget.accentColor,
          index: index,
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.item,
    required this.accentColor,
    required this.index,
  });

  final QuoteModel item;
  final Color accentColor;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          if (item.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 6,
                children: item.tags.take(3).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag.replaceAll('_', ' '),
                    style: AppTypography.labelSmall.copyWith(
                      color: accentColor,
                      fontSize: 10,
                    ),
                  ),
                )).toList(),
              ),
            ),

          // Quote text
          Text(
            item.text,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),

          // Author
          Text(
            '— ${item.author}',
            style: AppTypography.labelSmall.copyWith(
              color: accentColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
