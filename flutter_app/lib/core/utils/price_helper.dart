import 'dart:ui';

import '../constants/monetization_constants.dart';

/// Returns the localized price string based on the device's locale.
///
/// Falls back to USD if the locale's country is not in the price map.
class PriceHelper {
  PriceHelper._();

  static const _countryToCurrency = {
    'MX': 'MXN',
    'BR': 'BRL',
    'AR': 'ARS',
    'CO': 'USD', // Colombia uses USD pricing
    'CL': 'USD',
    'PE': 'USD',
    'ES': 'EUR',
    'DE': 'EUR',
    'FR': 'EUR',
    'IT': 'EUR',
    'US': 'USD',
    'GB': 'USD',
  };

  /// Returns the display price for the user's locale.
  static String localizedPrice() {
    final locale = PlatformDispatcher.instance.locale;
    final country = locale.countryCode?.toUpperCase() ?? '';
    final currency = _countryToCurrency[country] ?? 'USD';
    return MonetizationConstants.priceDisplay[currency] ?? r'$4.99';
  }
}
