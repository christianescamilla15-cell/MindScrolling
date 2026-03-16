/// Constants related to premium unlocking and donation flows.
class MonetizationConstants {
  MonetizationConstants._();

  // ------------------------------------------------------------------
  // Pricing
  // ------------------------------------------------------------------

  /// Base price in USD (used as a reference; localised prices are in
  /// [priceDisplay]).
  static const double basePriceUsd = 2.99;

  /// Human-readable price strings keyed by ISO 4217 currency code.
  static const Map<String, String> priceDisplay = {
    'USD': r'$2.99',
    'MXN': r'$59',
    'BRL': 'R\$14,90',
    'ARS': r'$299',
    'EUR': '€2.79',
  };

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
      'https://buymeacoffee.com/mindscroll';

  /// Returns the resolved donation URL.
  static String get donationUrl => const String.fromEnvironment(
        'DONATION_LINK',
        defaultValue: defaultDonationUrl,
      );
}
