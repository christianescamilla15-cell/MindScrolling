import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../constants/api_constants.dart';

/// Async singleton for [LocalStorage].
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return LocalStorage.getInstance();
});

/// Async singleton for [ApiClient] configured with the correct base URL.
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return ApiClient(baseUrl: ApiConstants.baseUrl, storage: storage);
});
