/// Builds standard HTTP request headers for the MindScroll API.
class HeadersBuilder {
  HeadersBuilder._();

  /// Builds the standard headers map.
  ///
  /// Always includes:
  /// - `Content-Type: application/json`
  /// - `Accept: application/json`
  /// - `X-Device-ID: <deviceId>`
  ///
  /// Optionally includes:
  /// - `Accept-Language: <lang>` when [lang] is provided and non-empty.
  static Map<String, String> build(
    String deviceId, {
    String? lang,
  }) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Device-ID': deviceId,
      if (lang != null && lang.isNotEmpty) 'Accept-Language': lang,
    };
  }
}
