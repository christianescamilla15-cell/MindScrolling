/// Date utility helpers used throughout the app.
///
/// Note: this class is named [AppDateUtils] to avoid conflicting with
/// Flutter's built-in [DateUtils].
class AppDateUtils {
  AppDateUtils._();

  // ------------------------------------------------------------------
  // Formatting
  // ------------------------------------------------------------------

  /// Returns today's date as an ISO-8601 date string: `'YYYY-MM-DD'`.
  static String todayString() {
    final now = DateTime.now();
    return _formatDate(now);
  }

  /// Formats [dt] as `'YYYY-MM-DD'`.
  static String formatDate(DateTime dt) => _formatDate(dt);

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ------------------------------------------------------------------
  // Comparison helpers
  // ------------------------------------------------------------------

  /// Returns `true` if [dateStr] (`'YYYY-MM-DD'`) represents today.
  static bool isToday(String dateStr) {
    return dateStr == todayString();
  }

  /// Returns `true` if [dateStr] (`'YYYY-MM-DD'`) represents yesterday.
  static bool isYesterday(String dateStr) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateStr == _formatDate(yesterday);
  }

  // ------------------------------------------------------------------
  // Relative formatting
  // ------------------------------------------------------------------

  /// Returns a human-readable relative label for [dt].
  ///
  /// - Same calendar day → `"Today"`
  /// - Previous calendar day → `"Yesterday"`
  /// - Otherwise → `"N days ago"`
  static String formatRelative(DateTime dt) {
    final today = _stripTime(DateTime.now());
    final target = _stripTime(dt);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  /// Returns a relative label localised for Spanish when [lang] is `'es'`.
  static String formatRelativeLocalized(DateTime dt, {String lang = 'en'}) {
    final today = _stripTime(DateTime.now());
    final target = _stripTime(dt);
    final diff = today.difference(target).inDays;

    if (lang == 'es') {
      if (diff == 0) return 'Hoy';
      if (diff == 1) return 'Ayer';
      return 'Hace $diff días';
    }

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  // ------------------------------------------------------------------
  // Internal helpers
  // ------------------------------------------------------------------

  static DateTime _stripTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
