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
    required this.status,
    required this.hintsUsed,
    required this.attempts,
  });

  final String id;
  final String title;
  final String description;
  final String language;

  /// Difficulty level 1–5.
  final int difficulty;
  final String category;
  final String? starterCode;
  final String? expectedOutput;
  final int points;

  /// Estimated completion time in minutes.
  final int estimatedTime;

  /// One of: not_started, in_progress, completed, skipped.
  final String status;
  final int hintsUsed;
  final int attempts;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
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
      status: (json['status'] as String?) ?? 'not_started',
      hintsUsed: (json['hints_used'] as int?) ?? 0,
      attempts: (json['attempts'] as int?) ?? 0,
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
      'status': status,
      'hints_used': hintsUsed,
      'attempts': attempts,
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
    String? status,
    int? hintsUsed,
    int? attempts,
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
      status: status ?? this.status,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
    );
  }
}
