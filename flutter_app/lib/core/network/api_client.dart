import 'dart:convert';

import 'package:http/http.dart' as http;

import 'headers_builder.dart';

/// Exception thrown when the server returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    required this.statusCode,
    this.body,
  });

  final String message;
  final int statusCode;
  final String? body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Low-level HTTP client that attaches device-ID headers and throws
/// [ApiException] for non-2xx responses.
///
/// Usage:
/// ```dart
/// final client = ApiClient(deviceId: id, baseUrl: ApiConstants.baseUrl);
/// final data = await client.get('/quotes/feed', queryParams: {'lang': 'en'});
/// ```
class ApiClient {
  ApiClient({
    required this.deviceId,
    required this.baseUrl,
    this.lang,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String deviceId;
  final String baseUrl;

  /// Optional language code forwarded as `Accept-Language`.
  final String? lang;

  final http.Client _http;

  // ------------------------------------------------------------------
  // Public request methods
  // ------------------------------------------------------------------

  /// Performs a GET request.
  ///
  /// [queryParams] are appended as URL query parameters.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    final response = await _http.get(uri, headers: _headers()).timeout(
      const Duration(seconds: 35),
      onTimeout: () => throw Exception('Request timeout — server may be starting up. Please try again.'),
    );
    return _handleResponse(response);
  }

  /// Performs a POST request with an optional JSON [body].
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _http.post(
      uri,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    ).timeout(
      const Duration(seconds: 35),
      onTimeout: () => throw Exception('Request timeout — server may be starting up. Please try again.'),
    );
    return _handleResponse(response);
  }

  /// Performs a DELETE request.
  Future<Map<String, dynamic>> delete(String path) async {
    final uri = _buildUri(path, null);
    final response = await _http.delete(uri, headers: _headers()).timeout(
      const Duration(seconds: 35),
      onTimeout: () => throw Exception('Request timeout — server may be starting up. Please try again.'),
    );
    return _handleResponse(response);
  }

  /// Closes the underlying HTTP client.
  void close() => _http.close();

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  Map<String, String> _headers() =>
      HeadersBuilder.build(deviceId, lang: lang);

  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final base = Uri.parse(baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path,
      queryParameters:
          (queryParams != null && queryParams.isNotEmpty) ? queryParams : null,
    );
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } catch (_) {
        return {'raw': response.body};
      }
    }

    String message = 'HTTP $statusCode';
    try {
      final err = jsonDecode(response.body);
      if (err is Map) {
        message = (err['error'] ?? message).toString();
      }
    } catch (_) {}

    switch (statusCode) {
      case 400:
        throw ApiException(message, statusCode: 400, body: response.body);
      case 401:
        throw ApiException('Unauthorized: $message',
            statusCode: 401, body: response.body);
      case 403:
        throw ApiException('Forbidden: $message',
            statusCode: 403, body: response.body);
      case 404:
        throw ApiException('Not found: $message',
            statusCode: 404, body: response.body);
      case 429:
        throw ApiException('Rate limited. Try again later.',
            statusCode: 429, body: response.body);
      default:
        throw ApiException(message,
            statusCode: statusCode, body: response.body);
    }
  }
}
