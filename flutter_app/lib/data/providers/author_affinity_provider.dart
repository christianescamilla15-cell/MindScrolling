import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Storage key
// ---------------------------------------------------------------------------

const _kAuthorAffinityKey = 'mindscroll_author_affinity';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable map of author name -> engagement score.
/// Like = +1 point. Vault save = +3 points.
class AuthorAffinityState {
  final Map<String, int> scores;

  const AuthorAffinityState({this.scores = const {}});

  /// Returns authors sorted by score descending, limited to [limit].
  List<MapEntry<String, int>> topAuthors({int limit = 5}) {
    final entries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AuthorAffinityNotifier extends StateNotifier<AuthorAffinityState> {
  AuthorAffinityNotifier() : super(const AuthorAffinityState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAuthorAffinityKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final scores = decoded.map((k, v) => MapEntry(k, v as int));
      state = AuthorAffinityState(scores: scores);
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthorAffinityKey, jsonEncode(state.scores));
  }

  /// Called when the user likes a quote (+1).
  Future<void> recordLike(String author) async {
    if (author.isEmpty) return;
    final updated = Map<String, int>.from(state.scores);
    updated[author] = (updated[author] ?? 0) + 1;
    state = AuthorAffinityState(scores: updated);
    await _persist();
  }

  /// Called when the user saves a quote to the vault (+3).
  Future<void> recordVaultSave(String author) async {
    if (author.isEmpty) return;
    final updated = Map<String, int>.from(state.scores);
    updated[author] = (updated[author] ?? 0) + 3;
    state = AuthorAffinityState(scores: updated);
    await _persist();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authorAffinityProvider =
    StateNotifierProvider<AuthorAffinityNotifier, AuthorAffinityState>(
  (ref) => AuthorAffinityNotifier(),
);
