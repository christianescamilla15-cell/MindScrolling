/// Constants for the multi-mode content system.
class ContentConstants {
  ContentConstants._();

  // ------------------------------------------------------------------
  // Content types
  // ------------------------------------------------------------------

  static const String philosophical = 'philosophical';
  static const String science = 'science';
  static const String coding = 'coding';

  static const List<String> allContentTypes = [philosophical, science, coding];

  // ------------------------------------------------------------------
  // Hidden modes
  // ------------------------------------------------------------------

  static const String scienceMode = 'science';
  static const String codingMode = 'coding';

  static const List<String> hiddenModes = [scienceMode, codingMode];

  // ------------------------------------------------------------------
  // Science sub-categories
  // ------------------------------------------------------------------

  static const String scienceGeneral = 'general_science';
  static const String physics = 'physics';
  static const String mathematics = 'mathematics';
  static const String technology = 'technology';

  static const List<String> scienceBranches = [
    scienceGeneral,
    physics,
    mathematics,
    technology,
  ];

  // ------------------------------------------------------------------
  // Coding sub-categories
  // ------------------------------------------------------------------

  static const String frontend = 'frontend';
  static const String backend = 'backend';
  static const String fundamentals = 'fundamentals';
  static const String devopsTools = 'devops_tools';

  static const List<String> codingBranches = [
    frontend,
    backend,
    fundamentals,
    devopsTools,
  ];

  // ------------------------------------------------------------------
  // Emotional / thematic tags for Insight matching
  // ------------------------------------------------------------------

  static const List<String> emotionalTags = [
    'sadness',
    'anxiety',
    'calm',
    'motivation',
    'focus',
    'learning',
    'curiosity',
    'discipline',
    'self_love',
    'reflection',
    'wisdom',
    'inner_strength',
    'meaning',
    'existence',
    'mindfulness',
    'self_improvement',
    'resilience',
    'creativity',
    'gratitude',
    'courage',
  ];

  // ------------------------------------------------------------------
  // Quiz gating
  // ------------------------------------------------------------------

  static const int quizQuestionCount = 10;
  static const int quizPassThreshold = 8;

  // ------------------------------------------------------------------
  // Pack pricing (display only — real prices from IAP)
  // ------------------------------------------------------------------

  static const String packPriceDisplay = r'$2.99';
  static const String insidePriceDisplay = r'$4.99';
}
