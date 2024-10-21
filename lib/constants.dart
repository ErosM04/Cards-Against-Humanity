const String appName = 'Cards Against Humanity';

const String seedInfo =
    'Il numero usato per pescare randomicamente le carte domanda e risposta di ogni giocatore. Questo numero dovrà essere uguale per tutti i giocatori.\n\n Si consiglia di usare numeri da almeno 10 cifre per rendere il gioco più casuale.';
const String totalPlayersInfo =
    'Il numero di giocatori che partecipano alla partita, da 3 a 20.';
const String playerNumberInfo =
    "Il tuo numero, che identifica il tuo turno.\n E' un numero da 1 fino al numero totale di giocatori";
const String cardsIdInput =
    """Inserire i numeri delle carte scelte dagli altri giocatori.

Esempio con 3 giocatori che scelgono le risposte:

Nel caso di una sola risposta per giocatore mettere i due numeri distanziati da un punto: 30.40.50

Nel caso di 2 risposte per giocatore mettere i due numeri di ogni giocatore distanziati da un punto e uno dopo l'altro: 30.31.40.41.50.51""";

const int maxPlayers = 20;
const int minPlayers = 3;
