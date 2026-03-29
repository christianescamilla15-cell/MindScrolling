import 'package:flutter_test/flutter_test.dart';
import 'package:mind_scrolling/features/feed/feed_state.dart';
import 'package:mind_scrolling/data/models/feed_item_model.dart';
import 'package:mind_scrolling/data/models/quote_model.dart';

void main() {
  group('FeedState', () {
    test('initial() creates loading state with empty items', () {
      final state = FeedState.initial();
      expect(state.isLoading, isTrue);
      expect(state.items, isEmpty);
      expect(state.currentIndex, 0);
      expect(state.reflections, 0);
      expect(state.streak, 0);
      expect(state.hasError, isFalse);
      expect(state.vault, isEmpty);
      expect(state.likedIds, isEmpty);
    });

    test('isEmpty returns true only when items empty and not loading', () {
      final loading = FeedState.initial();
      expect(loading.isEmpty, isFalse); // isLoading=true

      final empty = loading.copyWith(isLoading: false);
      expect(empty.isEmpty, isTrue);

      final withItems = loading.copyWith(
        isLoading: false,
        items: [const FeedItemModel.softPaywall()],
      );
      expect(withItems.isEmpty, isFalse);
    });

    test('currentItem returns item at currentIndex', () {
      final item = const FeedItemModel.softPaywall();
      final state = FeedState.initial().copyWith(
        items: [item],
        currentIndex: 0,
        isLoading: false,
      );
      expect(state.currentItem, item);
    });

    test('currentItem returns null when index out of bounds', () {
      final state = FeedState.initial().copyWith(
        items: [const FeedItemModel.softPaywall()],
        currentIndex: 5,
        isLoading: false,
      );
      expect(state.currentItem, isNull);
    });

    test('hasMore returns true when more items ahead', () {
      final state = FeedState.initial().copyWith(
        items: [
          const FeedItemModel.softPaywall(),
          const FeedItemModel.softPaywall(),
        ],
        currentIndex: 0,
        isLoading: false,
      );
      expect(state.hasMore, isTrue);

      final atEnd = state.copyWith(currentIndex: 1);
      expect(atEnd.hasMore, isFalse);
    });

    test('copyWith preserves toast null sentinel correctly', () {
      final state = FeedState.initial().copyWith(
        toastMessage: 'hello',
        toastColor: '#FF0000',
      );
      expect(state.toastMessage, 'hello');

      // Passing null should clear the value
      final cleared = state.copyWith(toastMessage: null, toastColor: null);
      expect(cleared.toastMessage, isNull);
      expect(cleared.toastColor, isNull);
    });

    test('copyWith without toast args preserves existing values', () {
      final state = FeedState.initial().copyWith(
        toastMessage: 'hello',
        toastColor: '#FF0000',
      );
      // copyWith without toast args should not change them
      final unchanged = state.copyWith(reflections: 5);
      expect(unchanged.toastMessage, 'hello');
      expect(unchanged.toastColor, '#FF0000');
    });

    test('totalSwiped sums all swipe counts', () {
      final state = FeedState.initial().copyWith(
        swipeCounts: {'stoicism': 5, 'existentialism': 3, 'zen': 2},
      );
      expect(state.totalSwiped, 10);
    });

    test('streak pulse can be set and cleared', () {
      final state = FeedState.initial().copyWith(streakPulse: true);
      expect(state.streakPulse, isTrue);

      final cleared = state.copyWith(streakPulse: false);
      expect(cleared.streakPulse, isFalse);
    });

    test('requestRating defaults to false', () {
      final state = FeedState.initial();
      expect(state.requestRating, isFalse);
    });
  });
}
