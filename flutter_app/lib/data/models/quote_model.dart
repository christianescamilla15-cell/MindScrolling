class QuoteModel {
  final String id;
  final String text;
  final String author;
  final String category;
  final String lang;
  final String swipeDir;
  final String packName;
  final bool isPremium;

  const QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.lang,
    required this.swipeDir,
    required this.packName,
    required this.isPremium,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      author: json['author'] as String? ?? '',
      category: json['category'] as String? ?? '',
      lang: json['lang'] as String? ?? 'en',
      swipeDir: json['swipe_dir'] as String? ?? '',
      packName: json['pack_name'] as String? ?? '',
      isPremium: json['is_premium'] as bool? ?? false,
    );
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
