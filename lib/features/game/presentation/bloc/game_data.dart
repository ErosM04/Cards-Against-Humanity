import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';

/// Stores the data ralated to the current state of the game.
class GameState {
  /// The specific number of the player between 0 and ``[_totalPlayers]``.
  int _playerNumber;

  /// The total number of players ([minPlayers]-[maxPlayers]).
  int _totalPlayers;

  /// The player hand, always containing 10 answer cards that he/she can use to complete a question card.
  final AnswerList _hand;

  /// The amount of rounds played so far.
  int _totalRounds;

  /// The amount of rounds that the player has played (excluding those played as the Master).
  int _playerRounds;

  /// The score of the player.
  int _score;

  /// The unique instance of the class.
  static final GameState? _instance;

  /// The specific number of the player between 0 and ``[_totalPlayers]``.
  int get playerNumber => _playerNumber;

  /// The total number of players ([minPlayers]-[maxPlayers]).
  int get totalPlayers => _totalPlayers;

  /// The amount of rounds played so far.
  int get totalRounds => _totalRounds;

  /// The amount of rounds that the player has played (excluding those played as the Master).
  int get playerRounds => _playerRounds;

  /// The score of the player.
  int get score => _score;

  /// The actual constructor that builds the object. If the number of player is not contained in the
  /// defined range, [RangeError] is thrown.
  GameState._privateConstructor({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  })  : _playerNumber = playerNumber,
        _totalPlayers = totalPlayers,
        _hand = hand,
        _totalRounds = 0,
        _playerRounds = -1,
        _score = 0 {
    if (_totalPlayers < minPlayers && _totalPlayers > maxPlayers) {
      throw RangeError(
          'Total players must be between $minPlayers and $maxPlayers');
    }
    if (_hand.length != 10) {
      throw FormatException(
          'The amount of cards contained in a hand must be between $minPlayers and $maxPlayers');
    }
  }

  factory GameState({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  }) =>
      _instance ??
      GameState._privateConstructor(
        playerNumber: playerNumber,
        totalPlayers: totalPlayers,
        hand: hand,
      );

  /// Resets the internal fata of the object. Used to start a new game.
  void resetState({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  }) =>
      GameState._privateConstructor(
        playerNumber: playerNumber,
        totalPlayers: totalPlayers,
        hand: hand,
      );

  /// Returns the amount of answer cards that must be skipped when drawing.
  /// This happens in order to avoid drawing the same cards of other players.
  /// The skip operation is based on the [totalPlayers].
  // int getAnswerSkip() =>
}
