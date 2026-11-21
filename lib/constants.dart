/// Full extended name of the app.
const String appName = 'Cards Against Humanity';

/// The instructions to help the user to insert the seed.
const String seedInfo =
    'Il numero usato per pescare randomicamente le carte domanda e risposta di ogni giocatore. Questo numero dovrà essere uguale per tutti i giocatori.\n\n Si consiglia di usare numeri da almeno 10 cifre per rendere il gioco più casuale.';

/// The instructions to help the user insert the number of players.
const String totalPlayersInfo =
    'Il numero di giocatori che partecipano alla partita, da 3 a 20.';

/// The instructions to help the user insert the player number.
const String playerNumberInfo =
    "Il tuo numero, che identifica il tuo turno.\n E' un numero da 1 fino al numero totale di giocatori";

/// The instructions to help the user, playing Master turn, select the seed.
const String cardsIdInput =
    """Inserire i numeri delle carte scelte dagli altri giocatori.

Esempio con 3 giocatori che scelgono le risposte:

Nel caso di una sola risposta per giocatore mettere i due numeri distanziati da un punto: 30.40.50

Nel caso di 2 risposte per giocatore mettere i due numeri di ogni giocatore distanziati da un punto e uno dopo l'altro: 30.31.40.41.50.51""";

/// The maximum number of players that can play in a single match.
const int maxPlayers = 20;

/// The minimum number of players that can play in a single match.
const int minPlayers = 3;

/// The amount of answer card that a plyer must have at the start of every turn.
const int handLength = 10;
