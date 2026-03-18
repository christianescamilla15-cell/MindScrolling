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
  /// Language is sent as a query parameter on each endpoint, not via header.
  static Map<String, String> build(String deviceId) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Device-ID': deviceId,
    };
  }
}
