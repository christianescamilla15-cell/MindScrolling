class SwipeEventModel {
  final String quoteId;
  final String direction;
  final String category;
  final int dwellTimeMs;

  /// Swipe source: 'feed' (default), 'pack', or 'preview'.
  final String source;

  /// Pack ID when source is 'pack' or 'preview', null for free feed.
  final String? sourcePackId;

  const SwipeEventModel({
    required this.quoteId,
    required this.direction,
    required this.category,
    required this.dwellTimeMs,
    this.source = 'feed',
    this.sourcePackId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quote_id': quoteId,
      'direction': direction,
      'category': category,
      'dwell_time_ms': dwellTimeMs,
      'source': source,
      if (sourcePackId != null) 'source_pack_id': sourcePackId,
    };
  }

  SwipeEventModel copyWith({
    String? quoteId,
    String? direction,
    String? category,
    int? dwellTimeMs,
    String? source,
    String? sourcePackId,
  }) {
    return SwipeEventModel(
      quoteId: quoteId ?? this.quoteId,
      direction: direction ?? this.direction,
      category: category ?? this.category,
      dwellTimeMs: dwellTimeMs ?? this.dwellTimeMs,
      source: source ?? this.source,
      sourcePackId: sourcePackId ?? this.sourcePackId,
    );
  }

  @override
  String toString() =>
      'SwipeEventModel(quoteId: $quoteId, direction: $direction, '
      'category: $category, dwellTimeMs: $dwellTimeMs, source: $source)';
}
