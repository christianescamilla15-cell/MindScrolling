class ChallengeModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String activeDate;

  const ChallengeModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.activeDate,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      activeDate: json['active_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'active_date': activeDate,
    };
  }

  static ChallengeModel get defaultChallenge => ChallengeModel(
        id: 'default',
        code: 'daily_reflection',
        title: 'Daily Reflection',
        description: 'Swipe 8 quotes with intention today.',
        activeDate: DateTime.now().toIso8601String().substring(0, 10),
      );

  ChallengeModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? activeDate,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      activeDate: activeDate ?? this.activeDate,
    );
  }

  @override
  String toString() =>
      'ChallengeModel(id: $id, code: $code, activeDate: $activeDate)';
}

class ChallengeProgressModel {
  final int progress;
  final bool completed;
  final int target;

  const ChallengeProgressModel({
    this.progress = 0,
    this.completed = false,
    this.target = 8,
  });

  factory ChallengeProgressModel.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressModel(
      progress: json['progress'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      target: json['target'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progress': progress,
      'completed': completed,
      'target': target,
    };
  }

  double get ratio => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  ChallengeProgressModel copyWith({
    int? progress,
    bool? completed,
    int? target,
  }) {
    return ChallengeProgressModel(
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      target: target ?? this.target,
    );
  }

  @override
  String toString() =>
      'ChallengeProgressModel(progress: $progress/$target, '
      'completed: $completed)';
}
