import 'package:cards_against_humanity/core/entities/data/card.dart';
import 'package:cards_against_humanity/core/entities/data/card_list.dart';
import 'dart:math';

/// Defines the methods that are used to manage the models and manipulate the data.
abstract interface class RandomCardSource<CardList> {
  /// Returns the next random card.
  CardAH getRandomCard();

  /// Returns the next random card and deletes it from the list.
  CardAH removeRandomCard();
}

/// Implements the methods that are used to manage the models and manipulate the data.
class RandomCardSourceImpl implements RandomCardSource<CardList> {
  /// The list of cards, with each being a [String].
  final CardList _cardList;

  /// The seed used by the ``[Random]`` object to generate randomic numbers.
  final int seed;

  /// The object used to generate random numbers, that correspond to the cards contained in ``[_cardList]``.
  final Random _randomCard;

  RandomCardSourceImpl({
    required this.seed,
    required CardList cardList,
  })  : _cardList = cardList,
        _randomCard = Random(seed);

  /// Getter that returns the next random number.
  int get _nextRandPos => _randomCard.nextInt(_cardList.length);

  @override
  CardAH getRandomCard() => _cardList.getCardAt(_nextRandPos);

  @override
  CardAH removeRandomCard() => _cardList.removeCardAt(_nextRandPos);
}
