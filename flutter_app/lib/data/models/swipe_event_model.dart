class SwipeEventModel {
  final String quoteId;
  final String direction;
  final String category;
  final int dwellTimeMs;

  const SwipeEventModel({
    required this.quoteId,
    required this.direction,
    required this.category,
    required this.dwellTimeMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'quote_id': quoteId,
      'direction': direction,
      'category': category,
      'dwell_time_ms': dwellTimeMs,
    };
  }

  SwipeEventModel copyWith({
    String? quoteId,
    String? direction,
    String? category,
    int? dwellTimeMs,
  }) {
    return SwipeEventModel(
      quoteId: quoteId ?? this.quoteId,
      direction: direction ?? this.direction,
      category: category ?? this.category,
      dwellTimeMs: dwellTimeMs ?? this.dwellTimeMs,
    );
  }

  @override
  String toString() =>
      'SwipeEventModel(quoteId: $quoteId, direction: $direction, '
      'category: $category, dwellTimeMs: $dwellTimeMs)';
}
