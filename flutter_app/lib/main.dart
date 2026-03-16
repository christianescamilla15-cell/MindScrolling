import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/providers/core_providers.dart';
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

  // Pre-load shared preferences so LocalStorage is ready
  await SharedPreferences.getInstance();

  // Resolve device ID once before the widget tree builds so
  // apiClientProvider can be a synchronous Provider<ApiClient>.
  final deviceId = await DeviceIdService.getOrCreate();

  runApp(
    ProviderScope(
      overrides: [
        deviceIdProvider.overrideWithValue(deviceId),
      ],
      child: const MindScrollApp(),
    ),
  );
}
