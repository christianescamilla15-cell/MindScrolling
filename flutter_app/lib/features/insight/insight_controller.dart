import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/core_providers.dart';
import '../../data/models/quote_model.dart';
import '../ambient/ambient_tracks.dart';
import '../hidden_modes/hidden_mode_detector.dart';
import '../settings/settings_controller.dart';
import 'emotional_theme.dart';

// ---------------------------------------------------------------------------
// Mood history entry
// ---------------------------------------------------------------------------

/// One persisted mood submission: the detected tags and the ISO date string.
class MoodEntry {
  final List<String> tags;
  final String date;

  const MoodEntry({required this.tags, required this.date});

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        tags: (json['tags'] as List?)?.whereType<String>().toList() ?? [],
        date: json['date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'tags': tags, 'date': date};
}

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

  /// Detected hidden mode intent: 'science', 'coding', or null.
  final String? detectedHiddenMode;

  /// Theme derived from [detectedTags] after a successful submission.
  final EmotionalTheme emotionalTheme;

  /// Last 30 mood submissions for the mood streak row (Feature 5).
  final List<MoodEntry> moodHistory;

  /// Suggested ambient track ID based on detected emotion (null = no suggestion).
  final String? suggestedTrackId;

  const InsightState({
    this.isLoading = false,
    this.inputText,
    this.quoteOfDay,
    this.matchedQuotes = const [],
    this.detectedTags = const [],
    this.error,
    this.hasSubmitted = false,
    this.detectedHiddenMode,
    this.emotionalTheme = EmotionalTheme.defaultTheme,
    this.moodHistory = const [],
    this.suggestedTrackId,
  });

  InsightState copyWith({
    bool? isLoading,
    String? inputText,
    QuoteModel? quoteOfDay,
    List<QuoteModel>? matchedQuotes,
    List<String>? detectedTags,
    String? error,
    bool? hasSubmitted,
    String? detectedHiddenMode,
    EmotionalTheme? emotionalTheme,
    List<MoodEntry>? moodHistory,
    String? suggestedTrackId,
  }) {
    return InsightState(
      isLoading: isLoading ?? this.isLoading,
      inputText: inputText ?? this.inputText,
      quoteOfDay: quoteOfDay ?? this.quoteOfDay,
      matchedQuotes: matchedQuotes ?? this.matchedQuotes,
      detectedTags: detectedTags ?? this.detectedTags,
      error: error,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      detectedHiddenMode: detectedHiddenMode ?? this.detectedHiddenMode,
      emotionalTheme: emotionalTheme ?? this.emotionalTheme,
      moodHistory: moodHistory ?? this.moodHistory,
      suggestedTrackId: suggestedTrackId ?? this.suggestedTrackId,
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
    // CRIT-03: Prevent concurrent submissions (rapid double-tap)
    if (state.isLoading) return;

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

      // Detect hidden mode intent from user text
      final hiddenModeIntent = HiddenModeDetector.detectIntent(text.trim());

      // Suggest ambient track based on emotion
      final suggestedTrack = trackForEmotion(detectedTags);

      // Derive emotional theme from tags
      final theme = EmotionalTheme.fromTags(detectedTags);

      // Persist mood entry locally for mood streak
      await _persistMoodEntry(detectedTags);

      // Fire-and-forget: save mood to backend
      try {
        api.post('/insight/mood', body: {
          'text': text.trim(),
          'tags': detectedTags,
          'lang': lang,
        }).catchError((_) => <String, dynamic>{});
      } catch (_) {}

      // HIGH-03: Load mood history independently — don't let local storage errors
      // discard successful API results
      List<MoodEntry> moodHistory;
      try {
        moodHistory = await _loadMoodHistory();
      } catch (_) {
        moodHistory = state.moodHistory;
      }

      state = state.copyWith(
        isLoading: false,
        quoteOfDay: quoteOfDay,
        matchedQuotes: matchedQuotes,
        detectedTags: detectedTags,
        hasSubmitted: true,
        detectedHiddenMode: hiddenModeIntent,
        emotionalTheme: theme,
        suggestedTrackId: suggestedTrack?.id,
        moodHistory: moodHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ── Mood history persistence ────────────────────────────────────────────

  static const _kMoodHistoryKey = 'mindscroll_mood_history';
  static const _maxMoodEntries = 30;

  Future<void> _persistMoodEntry(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMoodHistoryKey);
    final List<dynamic> existing = raw != null ? jsonDecode(raw) as List : [];
    existing.insert(0, MoodEntry(
      tags: tags,
      date: DateTime.now().toIso8601String(),
    ).toJson());
    if (existing.length > _maxMoodEntries) {
      existing.removeRange(_maxMoodEntries, existing.length);
    }
    await prefs.setString(_kMoodHistoryKey, jsonEncode(existing));
  }

  Future<List<MoodEntry>> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMoodHistoryKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => MoodEntry.fromJson(e))
          .toList();
    } catch (_) {
      return [];
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
