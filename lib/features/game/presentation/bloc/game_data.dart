import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';

/// Stores the data ralated to the current state of the game. It's a Singleton.
class GameData {
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
  int _score = 0;

  /// Pool of answer card IDs held by the other players (minus those played in Master turns).
  final List<int> _otherPlayersCardIds = [];

  /// The unique instance of the class.
  static GameData? _instance;

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

  /// Eligible answer card IDs tracked across the other players' hands.
  List<int> get otherPlayersCardIds => List.unmodifiable(_otherPlayersCardIds);

  /// THe number of card in the hand.
  int get hand => _hand.length;

  /// The hand of cards.
  AnswerList get handList => _hand;

  /// The actual constructor that builds the object. If the number of player is not contained in the
  /// defined range, [RangeError] is thrown.
  GameData._privateConstructor({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  })  : _playerNumber = playerNumber,
        _totalPlayers = totalPlayers,
        _hand = hand,
        _totalRounds = 0,
        _playerRounds = 0 {
    if (_totalPlayers < minPlayers || _totalPlayers > maxPlayers) {
      throw RangeError(
          'Il numero massimo di giocatori deve essere tra $minPlayers e $maxPlayers');
    }
    if (_hand.length != 10) {
      throw FormatException(
          'Il numero di carte nella mano deve essere $handLength');
    }
  }

  /// Constructor that stores data related to the current state of the game.
  /// This is a factory constructor used to implement a Singleton.
  factory GameData({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  }) =>
      _instance ??= GameData._privateConstructor(
        playerNumber: playerNumber,
        totalPlayers: totalPlayers,
        hand: hand,
      );

  /// Resets the internal data of the object. Used to start a new game.
  static void resetState({
    required int playerNumber,
    required int totalPlayers,
    required AnswerList hand,
  }) {
    _instance = GameData._privateConstructor(
      playerNumber: playerNumber,
      totalPlayers: totalPlayers,
      hand: hand,
    );
  }

  /// Increments the total rounds counter when a round starts.
  void newRound() {
    _totalRounds++;
  }

  /// Adds a new Answer card at the end of the hand.
  void addAnswerCard(Answer answer) {
    _hand.addCard(answer);
  }

  /// Removes an Answer card from the hand.
  bool removeAnswerCard(Answer answer) => _hand.removeCard(answer);

  /// Returns the 1-based Master player number for [round].
  int masterForRound(int round) => ((round - 1) % _totalPlayers) + 1;

  /// Checks whether a given round is played as Master by this player.
  bool isMasterRound(int round) => masterForRound(round) == _playerNumber;

  /// Adds an answer card [id] to the tracked eligible IDs of other players.
  void addOtherPlayerCardId(int id) => _otherPlayersCardIds.add(id);

  /// Removes played answer card [ids] from the tracked eligible IDs of other players.
  void removeOtherPlayerCardIds(Iterable<int> ids) {
    for (final id in ids) {
      _otherPlayersCardIds.remove(id);
    }
  }

  /// Records a completed non-Master round and increments [score] when [won].
  void recordPlayerRound({required bool won}) {
    _playerRounds++;
    if (won) _score++;
  }
}
