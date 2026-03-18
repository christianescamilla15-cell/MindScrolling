import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../../features/settings/settings_controller.dart';

/// Synchronous device-ID provider.
/// Overridden in main.dart with the real device ID before runApp().
final deviceIdProvider = Provider<String>((ref) => 'unset');

/// Synchronous [ApiClient] provider — no async needed because deviceId is
/// already resolved before the widget tree is built.
/// Watches [settingsStateProvider] to propagate lang as Accept-Language header.
final apiClientProvider = Provider<ApiClient>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  final lang = ref.watch(settingsStateProvider).lang;
  return ApiClient(deviceId: deviceId, baseUrl: ApiConstants.baseUrl, lang: lang);
});
