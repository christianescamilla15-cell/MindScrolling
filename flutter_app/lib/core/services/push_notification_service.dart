import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Handles Firebase Cloud Messaging for remote push notifications.
///
/// - Requests permission on first launch
/// - Registers FCM token with backend
/// - Handles foreground/background messages
class PushNotificationService {
  PushNotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static String? _cachedToken;

  /// Initialize FCM: request permission, get token, listen for messages.
  static Future<void> init(ApiClient apiClient) async {
    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM: Permission denied');
      return;
    }

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      _cachedToken = token;
      debugPrint('FCM token: ${token.substring(0, 20)}...');
      // Register token with backend
      _registerToken(apiClient, token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      _registerToken(apiClient, newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleMessageTap(initial);
    }
  }

  /// Register FCM token with backend for server-sent notifications.
  static Future<void> _registerToken(ApiClient apiClient, String token) async {
    try {
      await apiClient.post('/profile/fcm-token', body: {'token': token});
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  /// Handle foreground notification — show local notification.
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
    // Foreground messages don't show automatically on Android.
    // We could show a local notification here, but for now just log it.
  }

  /// Handle notification tap — navigate to relevant screen.
  static void _handleMessageTap(RemoteMessage message) {
    debugPrint('FCM tap: ${message.data}');
    // TODO: deep link based on message.data['type']
    // e.g., 'qotd' -> navigate to quote, 'social' -> social feed
  }

  /// Get cached FCM token.
  static String? get token => _cachedToken;
}

/// Top-level handler for background messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}
