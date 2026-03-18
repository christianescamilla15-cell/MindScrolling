import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../constants/api_constants.dart';

/// Synchronous device-ID provider.
/// Overridden in main.dart with the real device ID before runApp().
final deviceIdProvider = Provider<String>((ref) => 'unset');

/// Synchronous [ApiClient] provider — stable across lang changes.
/// Lang is NOT injected here to avoid a rebuild cascade that would destroy
/// feed state. All endpoints receive lang as a query param instead.
final apiClientProvider = Provider<ApiClient>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  return ApiClient(deviceId: deviceId, baseUrl: ApiConstants.baseUrl);
});
