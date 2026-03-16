/// String utility extensions used throughout MindScroll.
extension StringExtensions on String {
  /// Returns a copy of this string with the first character uppercased and
  /// the remainder unchanged.
  ///
  /// Returns an empty string if [this] is empty.
  ///
  /// Example:
  /// ```dart
  /// 'stoicism'.capitalize() // 'Stoicism'
  /// 'hello world'.capitalize() // 'Hello world'
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Returns this string truncated to [maxLen] characters (inclusive of the
  /// ellipsis suffix `'...'`).
  ///
  /// If the string is already within [maxLen] it is returned unchanged.
  /// [maxLen] must be greater than 3 so there is room for at least one
  /// content character before the ellipsis.
  ///
  /// Example:
  /// ```dart
  /// 'Hello, world!'.truncate(8) // 'Hello...'
  /// 'Hi'.truncate(8)            // 'Hi'
  /// ```
  String truncate(int maxLen) {
    assert(maxLen > 3, 'maxLen must be greater than 3');
    if (length <= maxLen) return this;
    return '${substring(0, maxLen - 3)}...';
  }
}
