import 'quote_model.dart';

enum FeedItemType { quote, reflectionCard, challengeCard, evolutionCard }

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

  bool get isQuote => type == FeedItemType.quote;
  bool get isReflectionCard => type == FeedItemType.reflectionCard;
  bool get isChallengeCard => type == FeedItemType.challengeCard;
  bool get isEvolutionCard => type == FeedItemType.evolutionCard;

  @override
  String toString() => 'FeedItemModel(type: $type, quoteId: ${quote?.id})';
}
