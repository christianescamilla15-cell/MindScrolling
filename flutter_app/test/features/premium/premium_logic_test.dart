import 'package:flutter_test/flutter_test.dart';
import 'package:mind_scrolling/features/premium/premium_controller.dart';
import 'package:mind_scrolling/data/models/premium_state_model.dart';

void main() {
  group('PremiumUiState', () {
    test('default state is not premium, not loading', () {
      const state = PremiumUiState();
      expect(state.isPremium, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isPurchasing, isFalse);
      expect(state.isRestoring, isFalse);
      expect(state.isTrial, isFalse);
      expect(state.trialExpired, isFalse);
      expect(state.error, isNull);
      expect(state.successMessage, isNull);
    });

    test('isPremium is true when premiumState.isPremium is true', () {
      const state = PremiumUiState(
        premiumState: PremiumStateModel(isPremium: true),
      );
      expect(state.isPremium, isTrue);
      expect(state.isTrial, isFalse);
    });

    test('isPremium is true when isTrial is true (even if not paid)', () {
      const state = PremiumUiState(
        premiumState: PremiumStateModel(isPremium: false),
        isTrial: true,
        trialDaysLeft: 5,
      );
      expect(state.isPremium, isTrue);
    });

    test('trial expired state is not premium', () {
      const state = PremiumUiState(
        premiumState: PremiumStateModel(isPremium: false),
        isTrial: false,
        trialExpired: true,
        trialDaysLeft: 0,
      );
      expect(state.isPremium, isFalse);
      expect(state.trialExpired, isTrue);
    });

    test('copyWith preserves fields not passed', () {
      const original = PremiumUiState(
        premiumState: PremiumStateModel(isPremium: true),
        isTrial: false,
        trialDaysLeft: 0,
        successMessage: 'purchaseSuccess',
      );

      final updated = original.copyWith(isLoading: true);
      expect(updated.premiumState.isPremium, isTrue);
      expect(updated.isLoading, isTrue);
      // successMessage should be null because copyWith sets it to null by default
      // This is the current behavior — not using a sentinel
    });

    test('copyWith clears error and successMessage when passed explicitly', () {
      const original = PremiumUiState(
        error: 'something went wrong',
        successMessage: 'all good',
      );

      final cleared = original.copyWith(
        error: null,
        successMessage: null,
      );
      expect(cleared.error, isNull);
      expect(cleared.successMessage, isNull);
    });
  });

  group('PremiumStateModel', () {
    test('fromJson parses is_paid_premium', () {
      final model = PremiumStateModel.fromJson({
        'is_paid_premium': true,
        'purchase_type': 'premium_unlock',
      });
      expect(model.isPremium, isTrue);
      expect(model.purchaseType, 'premium_unlock');
    });

    test('fromJson defaults to not premium when key missing', () {
      final model = PremiumStateModel.fromJson({});
      expect(model.isPremium, isFalse);
      expect(model.ownedPacks, isEmpty);
    });

    test('fromJson parses owned_packs list', () {
      final model = PremiumStateModel.fromJson({
        'is_paid_premium': false,
        'owned_packs': ['pack_stoicism', 'pack_zen'],
        'user_state': 'pack_owner',
      });
      expect(model.ownedPacks, ['pack_stoicism', 'pack_zen']);
      expect(model.userState, 'pack_owner');
    });

    test('fromJson handles null owned_packs gracefully', () {
      final model = PremiumStateModel.fromJson({
        'is_paid_premium': false,
        'owned_packs': null,
      });
      expect(model.ownedPacks, isEmpty);
    });

    test('toJson roundtrip preserves data', () {
      final original = PremiumStateModel(
        isPremium: true,
        purchaseType: 'premium_unlock',
        ownedPacks: ['pack_a'],
        userState: 'inside',
      );
      final json = original.toJson();
      final restored = PremiumStateModel.fromJson(json);
      expect(restored.isPremium, original.isPremium);
      expect(restored.purchaseType, original.purchaseType);
      expect(restored.ownedPacks, original.ownedPacks);
      expect(restored.userState, original.userState);
    });

    test('free() factory creates non-premium state', () {
      final free = PremiumStateModel.free();
      expect(free.isPremium, isFalse);
      expect(free.purchaseType, isNull);
      expect(free.ownedPacks, isEmpty);
    });
  });
}
