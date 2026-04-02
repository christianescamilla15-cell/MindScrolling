import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'core/analytics/event_logger.dart';
import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'core/providers/core_providers.dart';
import 'core/services/device_lock_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/utils/device_id.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F13),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase + FCM
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Pre-load shared preferences so LocalStorage is ready
  await SharedPreferences.getInstance();
  await NotificationService.init();

  // Resolve device ID once before the widget tree builds
  final deviceId = await DeviceIdService.getOrCreate();

  // Device registration (multi-device mode — no blocking)
  final apiClient = ApiClient(deviceId: deviceId, baseUrl: ApiConstants.baseUrl);
  await DeviceLockService.checkOrRegister(apiClient); // register for analytics, never blocks

  // Initialize FCM push notifications (fire-and-forget)
  PushNotificationService.init(apiClient).ignore();

  // Initialize home screen widget + update QOTD
  WidgetService.init().ignore();
  WidgetService.updateQuoteOfDay(apiClient).ignore();

  // Register device ID with EventLogger so analytics events include it
  EventLogger.setDeviceId(deviceId);
  EventLogger.logAppOpen();

  // Sentry DSN — set via --dart-define=SENTRY_DSN=https://...
  // If not set, Sentry is disabled (no-op)
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = 'production';
      },
      appRunner: () => _runApp(deviceId),
    );
  } else {
    _runApp(deviceId);
  }
}

void _runApp(String deviceId) {
  runApp(
    ProviderScope(
      overrides: [
        deviceIdProvider.overrideWithValue(deviceId),
      ],
      child: const MindScrollApp(),
    ),
  );
}
