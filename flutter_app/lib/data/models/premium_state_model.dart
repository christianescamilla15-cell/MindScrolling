class PremiumStateModel {
  final bool isPremium;
  final String? purchaseType;
  final DateTime? purchasedAt;

  const PremiumStateModel({
    this.isPremium = false,
    this.purchaseType,
    this.purchasedAt,
  });

  factory PremiumStateModel.fromJson(Map<String, dynamic> json) {
    DateTime? purchasedAt;
    final rawDate = json['purchased_at'];
    if (rawDate is String && rawDate.isNotEmpty) {
      purchasedAt = DateTime.tryParse(rawDate);
    }

    return PremiumStateModel(
      isPremium: json['is_premium'] as bool? ?? false,
      purchaseType: json['purchase_type'] as String?,
      purchasedAt: purchasedAt,
    );
  }

  factory PremiumStateModel.free() => const PremiumStateModel(isPremium: false);

  Map<String, dynamic> toJson() {
    return {
      'is_premium': isPremium,
      if (purchaseType != null) 'purchase_type': purchaseType,
      if (purchasedAt != null) 'purchased_at': purchasedAt!.toIso8601String(),
    };
  }

  PremiumStateModel copyWith({
    bool? isPremium,
    String? purchaseType,
    DateTime? purchasedAt,
  }) {
    return PremiumStateModel(
      isPremium: isPremium ?? this.isPremium,
      purchaseType: purchaseType ?? this.purchaseType,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  @override
  String toString() =>
      'PremiumStateModel(isPremium: $isPremium, '
      'purchaseType: $purchaseType)';
}
