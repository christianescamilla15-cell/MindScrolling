import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages daily and weekly local notifications for MindScrolling.
///
/// - Daily: "Your reflection awaits" at user-chosen time
/// - Weekly: "Your philosophy map is ready" on Sundays
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _kDailyHourKey = 'mindscroll_notif_hour';
  static const _kDailyMinuteKey = 'mindscroll_notif_minute';
  static const _kNotifEnabledKey = 'mindscroll_notif_enabled';

  static const _dailyId = 100;
  static const _weeklyId = 200;

  // ── Init ──────────────────────────────────────────────────────────────

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  // ── Permission ────────────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // ── Schedule daily ────────────────────────────────────────────────────

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDailyHourKey, hour);
    await prefs.setInt(_kDailyMinuteKey, minute);
    await prefs.setBool(_kNotifEnabledKey, true);

    await _plugin.cancel(_dailyId);

    await _plugin.periodicallyShow(
      _dailyId,
      title,
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reflection',
          'Daily Reflection',
          channelDescription: 'Daily philosophical reflection reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // ── Schedule weekly ───────────────────────────────────────────────────

  static Future<void> scheduleWeeklyMapReminder({
    required String title,
    required String body,
  }) async {
    await _plugin.cancel(_weeklyId);

    await _plugin.periodicallyShow(
      _weeklyId,
      title,
      body,
      RepeatInterval.weekly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_map',
          'Weekly Map',
          channelDescription: 'Weekly philosophy map update',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifEnabledKey, false);
  }

  // ── State ─────────────────────────────────────────────────────────────

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotifEnabledKey) ?? false;
  }

  static Future<TimeOfDay> getScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_kDailyHourKey) ?? 9;
    final minute = prefs.getInt(_kDailyMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
