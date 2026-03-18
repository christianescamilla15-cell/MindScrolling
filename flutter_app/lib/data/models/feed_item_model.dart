import 'quote_model.dart';

enum FeedItemType { quote, reflectionCard, challengeCard, evolutionCard, softPaywallCard }

class FeedItemModel {
  final FeedItemType type;
  final QuoteModel? quote;
  final Map<String, dynamic>? extra;

  const FeedItemModel._({
    required this.type,
    this.quote,
    this.extra,
  });

  const FeedItemModel.quote(QuoteModel q)
      : type = FeedItemType.quote,
        quote = q,
        extra = null;

  const FeedItemModel.challenge(Map<String, dynamic> data)
      : type = FeedItemType.challengeCard,
        quote = null,
        extra = data;

  const FeedItemModel.reflection()
      : type = FeedItemType.reflectionCard,
        quote = null,
        extra = null;

  const FeedItemModel.evolution(Map<String, dynamic> data)
      : type = FeedItemType.evolutionCard,
        quote = null,
        extra = data;

  /// Soft paywall card injected into the Trial feed at ~swipe 100.
  /// Swiping in any direction dismisses it without counting as a quote swipe.
  const FeedItemModel.softPaywall()
      : type = FeedItemType.softPaywallCard,
        quote = null,
        extra = null;

  bool get isQuote => type == FeedItemType.quote;
  bool get isReflectionCard => type == FeedItemType.reflectionCard;
  bool get isChallengeCard => type == FeedItemType.challengeCard;
  bool get isEvolutionCard => type == FeedItemType.evolutionCard;
  bool get isSoftPaywallCard => type == FeedItemType.softPaywallCard;

  @override
  String toString() => 'FeedItemModel(type: $type, quoteId: ${quote?.id})';
}
