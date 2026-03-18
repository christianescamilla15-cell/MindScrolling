class PremiumStateModel {
  final bool isPremium;
  final String? purchaseType;
  final DateTime? purchasedAt;

  /// Pack IDs the device is entitled to access in full.
  /// For Inside users this contains all grandfathered pack IDs.
  /// For pack owners it contains only purchased pack IDs.
  /// Empty for Free and Trial users with no purchases.
  /// Source: /premium/status → owned_packs field (Block B, API Contract §2).
  final List<String> ownedPacks;

  /// Canonical user state from backend: 'free' | 'trial' | 'inside' | 'pack_owner'.
  final String? userState;

  const PremiumStateModel({
    this.isPremium = false,
    this.purchaseType,
    this.purchasedAt,
    this.ownedPacks = const [],
    this.userState,
  });

  factory PremiumStateModel.fromJson(Map<String, dynamic> json) {
    DateTime? purchasedAt;
    final rawDate = json['purchased_at'];
    if (rawDate is String && rawDate.isNotEmpty) {
      purchasedAt = DateTime.tryParse(rawDate);
    }

    final rawPacks = json['owned_packs'];
    final ownedPacks = rawPacks is List
        ? rawPacks.whereType<String>().toList()
        : <String>[];

    return PremiumStateModel(
      isPremium: json['is_premium'] as bool? ?? false,
      purchaseType: json['purchase_type'] as String?,
      purchasedAt: purchasedAt,
      ownedPacks: ownedPacks,
      userState: json['user_state'] as String?,
    );
  }

  factory PremiumStateModel.free() => const PremiumStateModel(isPremium: false);

  Map<String, dynamic> toJson() {
    return {
      'is_premium': isPremium,
      if (purchaseType != null) 'purchase_type': purchaseType,
      if (purchasedAt != null) 'purchased_at': purchasedAt!.toIso8601String(),
      'owned_packs': ownedPacks,
      if (userState != null) 'user_state': userState,
    };
  }

  PremiumStateModel copyWith({
    bool? isPremium,
    String? purchaseType,
    DateTime? purchasedAt,
    List<String>? ownedPacks,
    String? userState,
  }) {
    return PremiumStateModel(
      isPremium: isPremium ?? this.isPremium,
      purchaseType: purchaseType ?? this.purchaseType,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      ownedPacks: ownedPacks ?? this.ownedPacks,
      userState: userState ?? this.userState,
    );
  }

  @override
  String toString() =>
      'PremiumStateModel(isPremium: $isPremium, '
      'purchaseType: $purchaseType, ownedPacks: $ownedPacks)';
}
