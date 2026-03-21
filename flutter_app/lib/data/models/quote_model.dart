class QuoteModel {
  final String id;
  final String text;
  final String author;
  final String category;
  final String lang;
  final String swipeDir;
  final String packName;
  final bool isPremium;

  /// Server-derived slug for author detail navigation.
  /// Falls back to client-side derivation if absent (backward compat).
  final String authorSlug;

  /// Content type: 'philosophical', 'science', 'coding'
  final String contentType;

  /// Finer categorization within category (e.g., 'physics', 'frontend', 'humanism')
  final String? subCategory;

  /// Emotional/thematic tags for Insight matching
  final List<String> tags;

  /// Which hidden mode locks this content (null = not locked)
  final String? lockedBy;

  /// Whether this content belongs to a hidden mode
  final bool isHiddenMode;

  const QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.lang,
    required this.swipeDir,
    required this.packName,
    required this.isPremium,
    required this.authorSlug,
    this.contentType = 'philosophical',
    this.subCategory,
    this.tags = const [],
    this.lockedBy,
    this.isHiddenMode = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as String? ?? '';
    final rawTags = json['tags'];
    final tags = rawTags is List
        ? rawTags.whereType<String>().toList()
        : <String>[];
    return QuoteModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      author: author,
      category: json['category'] as String? ?? '',
      lang: json['lang'] as String? ?? 'en',
      swipeDir: json['swipe_dir'] as String? ?? '',
      packName: json['pack_name'] as String? ?? '',
      isPremium: json['is_premium'] as bool? ?? false,
      authorSlug: json['author_slug'] as String? ?? _deriveSlug(author),
      contentType: json['content_type'] as String? ?? 'philosophical',
      subCategory: json['sub_category'] as String?,
      tags: tags,
      lockedBy: json['locked_by'] as String?,
      isHiddenMode: json['is_hidden_mode'] as bool? ?? false,
    );
  }

  /// Client-side slug fallback — mirrors backend authorSlug() in validation.js.
  /// Pre-maps non-decomposable Latin chars before stripping non-ASCII.
  /// The server-provided author_slug is always preferred over this fallback.
  static String _deriveSlug(String name) {
    return name
        .replaceAll(RegExp(r'[øØ]'), 'o')
        .replaceAll(RegExp(r'[ðÐ]'), 'd')
        .replaceAll(RegExp(r'[þÞ]'), 'th')
        .replaceAll(RegExp(r'[łŁ]'), 'l')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[æÆ]'), 'ae')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àáâãä]'), 'a')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'lang': lang,
      'swipe_dir': swipeDir,
      'pack_name': packName,
      'is_premium': isPremium,
      'author_slug': authorSlug,
      'content_type': contentType,
      if (subCategory != null) 'sub_category': subCategory,
      'tags': tags,
      if (lockedBy != null) 'locked_by': lockedBy,
      'is_hidden_mode': isHiddenMode,
    };
  }

  QuoteModel copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    String? lang,
    String? swipeDir,
    String? packName,
    bool? isPremium,
    String? authorSlug,
    String? contentType,
    String? subCategory,
    List<String>? tags,
    String? lockedBy,
    bool? isHiddenMode,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      lang: lang ?? this.lang,
      swipeDir: swipeDir ?? this.swipeDir,
      packName: packName ?? this.packName,
      isPremium: isPremium ?? this.isPremium,
      authorSlug: authorSlug ?? this.authorSlug,
      contentType: contentType ?? this.contentType,
      subCategory: subCategory ?? this.subCategory,
      tags: tags ?? this.tags,
      lockedBy: lockedBy ?? this.lockedBy,
      isHiddenMode: isHiddenMode ?? this.isHiddenMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'QuoteModel(id: $id, author: $author, category: $category)';
}
