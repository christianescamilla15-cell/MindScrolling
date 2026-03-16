/// Represents an AI-generated weekly philosophical insight for a device.
class InsightModel {
  final String insight;
  final DateTime? generatedAt;

  const InsightModel({
    required this.insight,
    this.generatedAt,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) => InsightModel(
        insight: json['insight'] as String,
        generatedAt: json['generated_at'] != null
            ? DateTime.tryParse(json['generated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'insight': insight,
        if (generatedAt != null) 'generated_at': generatedAt!.toIso8601String(),
      };
}
