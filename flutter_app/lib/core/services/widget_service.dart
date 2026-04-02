import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Manages the Android/iOS home screen widget for Quote of the Day.
class WidgetService {
  WidgetService._();

  static const _androidProvider = 'QuoteOfDayWidgetProvider';
  static const _iOSName = 'QuoteOfDayWidget';

  /// Initialize home widget and set initial data.
  static Future<void> init() async {
    await HomeWidget.setAppGroupId('group.com.mindscrolling.app');
  }

  /// Fetch QOTD from backend and update the widget.
  static Future<void> updateQuoteOfDay(ApiClient apiClient, {String lang = 'en'}) async {
    try {
      final res = await apiClient.get('/social/qotd?lang=$lang');
      final quote = res['quote'] as Map<String, dynamic>?;

      if (quote != null) {
        await HomeWidget.saveWidgetData('quote_text', quote['text'] ?? '');
        await HomeWidget.saveWidgetData('quote_author', quote['author'] ?? '');
        await HomeWidget.saveWidgetData('quote_category', quote['category'] ?? '');
        await HomeWidget.updateWidget(
          androidName: _androidProvider,
          iOSName: _iOSName,
        );
        debugPrint('Widget updated: ${quote['author']}');
      }
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }
}
