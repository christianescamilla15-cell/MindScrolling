import 'package:flutter/material.dart';

/// Maps a list of detected emotional tags to a visual color theme.
///
/// Used to subtly tint the InsightPanel gradient and accent color after the
/// user submits a feeling and results are returned.
class EmotionalTheme {
  const EmotionalTheme({
    required this.accent,
    required this.background,
    required this.label,
  });

  final Color accent;
  final Color background;
  final String label;

  // ---------------------------------------------------------------------------
  // Named themes
  // ---------------------------------------------------------------------------

  static const calm = EmotionalTheme(
    accent: Color(0xFF60A5FA),      // soft blue
    background: Color(0xFF0D1B2A),
    label: 'calm',
  );

  static const motivation = EmotionalTheme(
    accent: Color(0xFFF59E0B),      // warm amber
    background: Color(0xFF1F1500),
    label: 'motivation',
  );

  static const reflection = EmotionalTheme(
    accent: Color(0xFFA78BFA),      // gentle purple
    background: Color(0xFF130D1F),
    label: 'reflection',
  );

  static const wisdom = EmotionalTheme(
    accent: Color(0xFF14B8A6),      // teal
    background: Color(0xFF001A19),
    label: 'wisdom',
  );

  static const existence = EmotionalTheme(
    accent: Color(0xFF6366F1),      // deep indigo
    background: Color(0xFF0D0F1F),
    label: 'existence',
  );

  static const gratitude = EmotionalTheme(
    accent: Color(0xFFF472B6),      // rose
    background: Color(0xFF1F0A15),
    label: 'gratitude',
  );

  static const defaultTheme = EmotionalTheme(
    accent: Color(0xFF8B5CF6),      // current purple
    background: Color(0xFF1A1A2E),
    label: 'default',
  );

  // ---------------------------------------------------------------------------
  // Tag -> theme mapping
  // ---------------------------------------------------------------------------

  static const _tagMap = <String, EmotionalTheme>{
    'calm':        calm,
    'mindfulness': calm,
    'peace':       calm,
    'serenity':    calm,
    'motivation':  motivation,
    'courage':     motivation,
    'ambition':    motivation,
    'strength':    motivation,
    'sadness':     reflection,
    'reflection':  reflection,
    'melancholy':  reflection,
    'grief':       reflection,
    'wisdom':      wisdom,
    'learning':    wisdom,
    'knowledge':   wisdom,
    'growth':      wisdom,
    'existence':   existence,
    'meaning':     existence,
    'purpose':     existence,
    'philosophy':  existence,
    'self_love':   gratitude,
    'gratitude':   gratitude,
    'love':        gratitude,
    'joy':         gratitude,
  };

  /// Returns the dominant [EmotionalTheme] for the given list of tags.
  ///
  /// Iterates [tags] in order and returns the first tag that maps to a known
  /// theme. Falls back to [defaultTheme] when no tags match.
  static EmotionalTheme fromTags(List<String> tags) {
    for (final tag in tags) {
      final theme = _tagMap[tag.toLowerCase()];
      if (theme != null) return theme;
    }
    return defaultTheme;
  }
}
