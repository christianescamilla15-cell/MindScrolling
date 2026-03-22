import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/models/quote_model.dart';
import '../settings/settings_controller.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class InsightState {
  final bool isLoading;
  final String? inputText;
  final QuoteModel? quoteOfDay;
  final List<QuoteModel> matchedQuotes;
  final List<String> detectedTags;
  final String? error;
  final bool hasSubmitted;

  const InsightState({
    this.isLoading = false,
    this.inputText,
    this.quoteOfDay,
    this.matchedQuotes = const [],
    this.detectedTags = const [],
    this.error,
    this.hasSubmitted = false,
  });

  InsightState copyWith({
    bool? isLoading,
    String? inputText,
    QuoteModel? quoteOfDay,
    List<QuoteModel>? matchedQuotes,
    List<String>? detectedTags,
    String? error,
    bool? hasSubmitted,
  }) {
    return InsightState(
      isLoading: isLoading ?? this.isLoading,
      inputText: inputText ?? this.inputText,
      quoteOfDay: quoteOfDay ?? this.quoteOfDay,
      matchedQuotes: matchedQuotes ?? this.matchedQuotes,
      detectedTags: detectedTags ?? this.detectedTags,
      error: error,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class InsightController extends StateNotifier<InsightState> {
  InsightController({required this.ref}) : super(const InsightState());

  final Ref ref;

  /// Submit emotional text and get personalized quote matches.
  Future<void> submitFeeling(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      inputText: text,
      error: null,
    );

    try {
      final api = ref.read(apiClientProvider);
      final lang = ref.read(settingsStateProvider).lang;

      final response = await api.post('/insight/match', body: {
        'text': text.trim(),
        'lang': lang,
        'limit': 10,
      });

      final rawQuoteOfDay = response['quote_of_day'] as Map<String, dynamic>?;
      final rawData = response['data'] as List? ?? [];
      final rawTags = response['tags_detected'] as List? ?? [];

      final quoteOfDay = rawQuoteOfDay != null
          ? QuoteModel.fromJson(rawQuoteOfDay)
          : null;

      final matchedQuotes = rawData
          .whereType<Map<String, dynamic>>()
          .map((q) => QuoteModel.fromJson(q))
          .toList();

      final detectedTags = rawTags.whereType<String>().toList();

      state = state.copyWith(
        isLoading: false,
        quoteOfDay: quoteOfDay,
        matchedQuotes: matchedQuotes,
        detectedTags: detectedTags,
        hasSubmitted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear the current insight and reset to input state.
  void reset() {
    state = const InsightState();
  }

  /// Refine the suggestion with updated text.
  Future<void> refine(String text) async {
    await submitFeeling(text);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final insightControllerProvider =
    StateNotifierProvider<InsightController, InsightState>((ref) {
  return InsightController(ref: ref);
});
