import '../../data/models/feed_item_model.dart';
import '../../data/models/quote_model.dart';

/// Immutable snapshot of the feed screen state.
class FeedState {
  final List<FeedItemModel> items;
  final int currentIndex;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final Map<String, int> swipeCounts;
  final int streak;
  final int reflections;
  final bool streakPulse;
  final Set<String> likedIds;
  final List<QuoteModel> vault;
  final bool showVault;
  final String? toastMessage;
  final String? toastColor;
  final bool requestRating;

  const FeedState({
    required this.items,
    required this.currentIndex,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.swipeCounts,
    required this.streak,
    required this.reflections,
    required this.streakPulse,
    required this.likedIds,
    required this.vault,
    required this.showVault,
    this.toastMessage,
    this.toastColor,
    this.requestRating = false,
  });

  static FeedState initial() => const FeedState(
        items: [],
        currentIndex: 0,
        isLoading: true,
        hasError: false,
        errorMessage: null,
        swipeCounts: {},
        streak: 0,
        reflections: 0,
        streakPulse: false,
        likedIds: {},
        vault: [],
        showVault: false,
        toastMessage: null,
        toastColor: null,
        requestRating: false,
      );

  FeedState copyWith({
    List<FeedItemModel>? items,
    int? currentIndex,
    bool? isLoading,
    bool? hasError,
    Object? errorMessage = _sentinel,
    Map<String, int>? swipeCounts,
    int? streak,
    int? reflections,
    bool? streakPulse,
    Set<String>? likedIds,
    List<QuoteModel>? vault,
    bool? showVault,
    Object? toastMessage = _sentinel,
    Object? toastColor = _sentinel,
    bool? requestRating,
  }) {
    return FeedState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      swipeCounts: swipeCounts ?? this.swipeCounts,
      streak: streak ?? this.streak,
      reflections: reflections ?? this.reflections,
      streakPulse: streakPulse ?? this.streakPulse,
      likedIds: likedIds ?? this.likedIds,
      vault: vault ?? this.vault,
      showVault: showVault ?? this.showVault,
      toastMessage:
          toastMessage == _sentinel ? this.toastMessage : toastMessage as String?,
      toastColor:
          toastColor == _sentinel ? this.toastColor : toastColor as String?,
      requestRating: requestRating ?? this.requestRating,
    );
  }

  // Sentinel object used to distinguish null-passed vs not-passed in copyWith.
  static const Object _sentinel = Object();

  // ------------------------------------------------------------------
  // Derived getters
  // ------------------------------------------------------------------

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get hasMore => currentIndex < items.length - 1;

  FeedItemModel? get currentItem =>
      (currentIndex < items.length) ? items[currentIndex] : null;

  FeedItemModel? get nextItem =>
      (currentIndex + 1 < items.length) ? items[currentIndex + 1] : null;

  int get totalSwiped => swipeCounts.values.fold(0, (a, b) => a + b);
}
