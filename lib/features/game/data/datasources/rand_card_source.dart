/// Defines the methods that are used to manage the models and manipulate the data.
abstract interface class RandomCardSource<Card> {
  /// Returns a card at a specific index.
  Card getCardAt(int index);

  /// Returns the next random card.
  /// Throws [RangeError] if there are no more cards in the list.
  Card getRandomCard();

  /// Returns the next random card and deletes it from the list.
  /// Throws [RangeError] if there are no more cards in the list.
  Card removeRandomCard();
}

// /// Implements the methods that are used to manage the models and manipulate the data,
// /// specifically for the question cards.
// abstract class RandomCardSourceImpl<Card>
//     implements RandomCardSource<Card, CardList> {
//   /// The list of question cards.
//   final CardList _questionList;

//   /// The seed used by the ``[Random]`` object to generate randomic numbers.
//   final int seed;

//   /// The object used to generate random numbers, that correspond to the question cards contained
//   /// in ``[_questionList]``.
//   final Random _randomCard;

//   RandomCardSourceImpl({
//     required this.seed,
//     required CardList questionList,
//   })  : _questionList = questionList,
//         _randomCard = Random(seed);

//   /// Getter that returns the next random number.
//   int get nextRandPos => _randomCard.nextInt(_questionList.length);
// }

// class RandomQuestionSource extends RandomCardSourceImpl<Answer> {
//   RandomQuestionSource({
//     required super.seed,
//     required QuestionList questionList,
//   }) : super(questionList: questionList);

//   @override
//   Answer getRandomCard() {
//     try {
//       return _questionList.getCardAt(nextRandPos) as Answer;
//     } catch (e) {
//       throw RangeError(e.toString());
//     }
//   }

//   @override
//   Answer removeRandomCard() {
//     try {
//       return _questionList.removeCardAt(nextRandPos) as Answer;
//     } catch (e) {
//       throw RangeError(e.toString());
//     }
//   }
// }

// class RandomAnswerSource extends RandomCardSourceImpl<Answer> {
//   RandomAnswerSource({
//     required super.seed,
//     required AnswerList answerList,
//   }) : super(questionList: answerList);

//   @override
//   Answer getRandomCard() {
//     try {
//       return _questionList.getCardAt(nextRandPos) as Answer;
//     } catch (e) {
//       throw RangeError(e.toString());
//     }
//   }

//   @override
//   Answer removeRandomCard() {
//     try {
//       return _questionList.removeCardAt(nextRandPos) as Answer;
//     } catch (e) {
//       throw RangeError(e.toString());
//     }
//   }
// }
