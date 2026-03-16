class PhilosophyScores {
  final double wisdom;
  final double discipline;
  final double reflection;
  final double philosophy;

  const PhilosophyScores({
    required this.wisdom,
    required this.discipline,
    required this.reflection,
    required this.philosophy,
  });

  factory PhilosophyScores.fromJson(Map<String, dynamic> json) {
    return PhilosophyScores(
      wisdom: (json['wisdom'] as num?)?.toDouble() ?? 0.0,
      discipline: (json['discipline'] as num?)?.toDouble() ?? 0.0,
      reflection: (json['reflection'] as num?)?.toDouble() ?? 0.0,
      philosophy: (json['philosophy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PhilosophyScores.zero() => const PhilosophyScores(
        wisdom: 0,
        discipline: 0,
        reflection: 0,
        philosophy: 0,
      );

  Map<String, double> toMap() => {
        'wisdom': wisdom,
        'discipline': discipline,
        'reflection': reflection,
        'philosophy': philosophy,
      };

  Map<String, dynamic> toJson() => toMap().map(
        (key, value) => MapEntry(key, value),
      );

  double get total => wisdom + discipline + reflection + philosophy;

  double normalized(String key) {
    if (total <= 0) return 0;
    return (toMap()[key] ?? 0) / total;
  }

  PhilosophyScores copyWith({
    double? wisdom,
    double? discipline,
    double? reflection,
    double? philosophy,
  }) {
    return PhilosophyScores(
      wisdom: wisdom ?? this.wisdom,
      discipline: discipline ?? this.discipline,
      reflection: reflection ?? this.reflection,
      philosophy: philosophy ?? this.philosophy,
    );
  }

  @override
  String toString() =>
      'PhilosophyScores(wisdom: $wisdom, discipline: $discipline, '
      'reflection: $reflection, philosophy: $philosophy)';
}

class PhilosophyMapModel {
  final PhilosophyScores current;
  final PhilosophyScores? snapshot;
  final String? snapshotDate;

  const PhilosophyMapModel({
    required this.current,
    this.snapshot,
    this.snapshotDate,
  });

  factory PhilosophyMapModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>?;
    final snapshotJson = json['snapshot'] as Map<String, dynamic>?;

    return PhilosophyMapModel(
      current: currentJson != null
          ? PhilosophyScores.fromJson(currentJson)
          : PhilosophyScores.zero(),
      snapshot:
          snapshotJson != null ? PhilosophyScores.fromJson(snapshotJson) : null,
      snapshotDate: json['snapshot_date'] as String?,
    );
  }

  factory PhilosophyMapModel.empty() => PhilosophyMapModel(
        current: PhilosophyScores.zero(),
      );

  @override
  String toString() =>
      'PhilosophyMapModel(current: $current, snapshotDate: $snapshotDate)';
}
