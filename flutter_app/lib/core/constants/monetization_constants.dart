/// Constants related to premium unlocking and donation flows.
class MonetizationConstants {
  MonetizationConstants._();

  // ------------------------------------------------------------------
  // Pricing
  // ------------------------------------------------------------------

  /// Base price in USD (used as a reference; localised prices are in
  /// [priceDisplay]).
  static const double basePriceUsd = 4.99;

  /// Human-readable price strings keyed by ISO 4217 currency code.
  static const Map<String, String> priceDisplay = {
    'USD': r'$4.99',
    'MXN': r'$99',
    'BRL': 'R\$24,90',
    'ARS': r'$499',
    'EUR': '€4.59',
  };

  /// In-app purchase product ID (same for Android and iOS).
  static const String iapProductId = 'com.mindscrolling.inside';

  // ------------------------------------------------------------------
  // In-app purchase
  // ------------------------------------------------------------------

  /// Product / purchase type identifier used with the payments backend.
  static const String premiumPurchaseType = 'premium_unlock';

  // ------------------------------------------------------------------
  // Donations
  // ------------------------------------------------------------------

  /// Environment variable key that, if set, overrides the donation URL.
  /// Override at build time:
  ///   flutter run --dart-define=DONATION_LINK=https://your-link.com
  static const String donationLinkEnvKey = 'DONATION_LINK';

  /// Fallback donation URL when [donationLinkEnvKey] is not provided.
  static const String defaultDonationUrl =
      'https://buymeacoffee.com/mindscrolling';

  /// Returns the resolved donation URL.
  static String get donationUrl => const String.fromEnvironment(
        'DONATION_LINK',
        defaultValue: defaultDonationUrl,
      );
}
