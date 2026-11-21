import 'dart:math';
import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_answer_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RandomAnswersSource card skipping', () {
    late AnswerListModel answerList;
    const int seed = 12345;

    setUp(() {
      answerList = AnswerListModel(
        answers: List.generate(
          100,
          (i) => AnswerModel(id: i, text: 'Answer $i'),
        ),
      );
    });

    test('skipCards advances the PRNG by the specified amount', () {
      final source1 = RandomAnswersSource(seed: seed, answerList: answerList);
      final source2 = RandomAnswersSource(seed: seed, answerList: answerList);

      // source1 skips 5 cards then draws
      source1.skipCards(5);
      final card1 = source1.getRandomCard();

      // source2 draws 6 cards sequentially
      for (var i = 0; i < 5; i++) {
        source2.getRandomCard();
      }
      final card2 = source2.getRandomCard();

      expect(card1.id, equals(card2.id));
      expect(card1.text, equals(card2.text));
    });

    test('getRandomCardWithSkip synchronizes across all players in a match', () {
      const int totalPlayers = 4;

      // 4 separate devices with their own RandomAnswersSource instance
      final playerSources = List.generate(
        totalPlayers,
        (_) => RandomAnswersSource(seed: seed, answerList: answerList),
      );

      // Raw reference PRNG to verify exact draws
      final rawRandom = Random(seed);

      // Test across 3 dealing rounds (e.g. 3 cards dealt to each player)
      for (var round = 0; round < 3; round++) {
        final expectedIds = List.generate(
          totalPlayers,
          (_) => rawRandom.nextInt(100),
        );

        for (var p = 0; p < totalPlayers; p++) {
          final drawnCard = playerSources[p].getRandomCardWithSkip(
            totalPlayers: totalPlayers,
            playerNumber: p + 1,
          );
          expect(drawnCard.id, equals(expectedIds[p]));
        }
      }
    });

    test('getRandomCardWithSkip throws RangeError on invalid playerNumber', () {
      final source = RandomAnswersSource(seed: seed, answerList: answerList);

      expect(
        () => source.getRandomCardWithSkip(totalPlayers: 4, playerNumber: 0),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => source.getRandomCardWithSkip(totalPlayers: 4, playerNumber: 5),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
