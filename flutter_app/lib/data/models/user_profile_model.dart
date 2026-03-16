class UserProfileModel {
  final String? ageRange;
  final String? interest;
  final String? goal;
  final String preferredLanguage;

  const UserProfileModel({
    this.ageRange,
    this.interest,
    this.goal,
    this.preferredLanguage = 'en',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      ageRange: json['age_range'] as String?,
      interest: json['interest'] as String?,
      goal: json['goal'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ageRange != null) 'age_range': ageRange,
      if (interest != null) 'interest': interest,
      if (goal != null) 'goal': goal,
      'preferred_language': preferredLanguage,
    };
  }

  UserProfileModel copyWith({
    String? ageRange,
    String? interest,
    String? goal,
    String? preferredLanguage,
  }) {
    return UserProfileModel(
      ageRange: ageRange ?? this.ageRange,
      interest: interest ?? this.interest,
      goal: goal ?? this.goal,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  bool get isComplete =>
      ageRange != null && interest != null && goal != null;

  static const List<String> ageRanges = ['18-24', '25-34', '35-44', '45+'];

  static const List<String> interests = [
    'philosophy',
    'stoicism',
    'personal_growth',
    'mindfulness',
    'curiosity',
  ];

  static const List<String> goals = [
    'calm_mind',
    'discipline',
    'meaning',
    'emotional_clarity',
  ];

  @override
  String toString() =>
      'UserProfileModel(ageRange: $ageRange, interest: $interest, '
      'goal: $goal, lang: $preferredLanguage)';
}
