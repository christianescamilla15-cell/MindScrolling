/// Data model for a coding exercise in the Practice Console.
class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.difficulty,
    required this.category,
    this.starterCode,
    this.expectedOutput,
    required this.points,
    required this.estimatedTime,
    required this.hintCount,
    required this.status,
    required this.hintsUsed,
    required this.attempts,
    this.pointsEarned,
  });

  final String id;
  final String title;
  final String description;
  final String language;
  final int difficulty;
  final String category;
  final String? starterCode;
  final String? expectedOutput;
  final int points;
  final int estimatedTime;
  final int hintCount;
  final String status;
  final int hintsUsed;
  final int attempts;
  final int? pointsEarned;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    // MED-01: Progress may be nested under 'progress' (list endpoint)
    // or flat at top level (detail endpoint). Handle both.
    final progress = json['progress'] as Map<String, dynamic>?;

    return ExerciseModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      language: (json['language'] as String?) ?? 'javascript',
      difficulty: (json['difficulty'] as int?) ?? 1,
      category: (json['category'] as String?) ?? '',
      starterCode: json['starter_code'] as String?,
      expectedOutput: json['expected_output'] as String?,
      points: (json['points'] as int?) ?? 10,
      estimatedTime: (json['estimated_time'] as int?) ?? 5,
      hintCount: (json['hint_count'] as int?) ?? 3,
      status: (progress?['status'] as String?) ??
              (json['status'] as String?) ?? 'not_started',
      hintsUsed: (progress?['hints_used'] as int?) ??
                 (json['hints_used'] as int?) ?? 0,
      attempts: (progress?['attempts'] as int?) ??
                (json['attempts'] as int?) ?? 0,
      pointsEarned: (progress?['points_earned'] as int?) ??
                    (json['points_earned'] as int?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'difficulty': difficulty,
      'category': category,
      'starter_code': starterCode,
      'expected_output': expectedOutput,
      'points': points,
      'estimated_time': estimatedTime,
      'hint_count': hintCount,
      'status': status,
      'hints_used': hintsUsed,
      'attempts': attempts,
      if (pointsEarned != null) 'points_earned': pointsEarned,
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    int? difficulty,
    String? category,
    String? starterCode,
    String? expectedOutput,
    int? points,
    int? estimatedTime,
    int? hintCount,
    String? status,
    int? hintsUsed,
    int? attempts,
    int? pointsEarned,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      starterCode: starterCode ?? this.starterCode,
      expectedOutput: expectedOutput ?? this.expectedOutput,
      points: points ?? this.points,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      hintCount: hintCount ?? this.hintCount,
      status: status ?? this.status,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}
