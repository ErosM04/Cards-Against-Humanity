# Cards Against Humanity - Architecture & System Documentation

This document serves as the architectural reference and onboarding guide for developers and AI agents working on the Flutter/Dart implementation of **Cards Against Humanity** (Italian localization).

---

## 1. Game Overview & Mechanics

### 1.1 Core Concept: Offline Synchronized Multiplayer
The application allows 3 to 20 players in the same room to play Cards Against Humanity on Android devices **without requiring an internet connection, Wi-Fi network, or Bluetooth pairing**.

Synchronization is achieved entirely through a **deterministic pseudo-random number generator (PRNG)** seeded with a shared game key (*"Codice partita"*):
- Every player enters the exact same integer seed on the start screen.
- A player enters the total number of players ($N \in [3, 20]$) and their unique 1-based player index ($P \in [1, N]$).
- Because `Random(seed)` produces an identical sequence of pseudo-random numbers across all devices running Dart, game state can remain consistent across separate devices as long as the PRNG consumption order is strictly synchronized.

### 1.2 PRNG Synchronization Protocol
1. **Question Card Drawing**:
   - Uses `Random(seed + 1)`.
   - In each round, every device draws the next question card at the same sequential position. Once used, the card is removed from the local pool so questions do not repeat.
2. **Answer Card Drawing & Player Hands**:
   - Uses `Random(seed)`.
   - Players start with a hand of 10 answer cards (`handLength = 10`).
   - When dealing cards, the PRNG advances by $N$ steps (one step per total player). Device $P$ keeps only the card drawn at its slot $(P - 1)$ and discards the rest from its active hand, guaranteeing that:
     - Every player receives distinct answer cards.
     - The PRNG sequence remains synchronized across all devices regardless of individual device actions.
   - When cards are played, new cards are drawn using the same interleaved PRNG sequence to maintain a hand of 10 cards.

### 1.3 Turn Structure & Roles
Rounds rotate sequentially among players from Player 1 to Player $N$:
- **Master Turn (Judge)**:
  - If $\text{round} \pmod N = P \pmod N$ (or $P = N$ when $\text{round} \pmod N = 0$), the player acts as the **Master** (Giudice).
  - The Master does not submit an answer card and does not earn score points during this round.
  - The Master screen displays the question card and a text input field.
  - Normal players verbally communicate their chosen card ID(s) to the Master.
  - The Master inputs the IDs separated by dots (`.`), e.g.:
    - Single-answer question: `96.445.237`
    - Two-answer question: `55.24.7.255.743.112` (subsequent numbers from the same player).
  - Tapping **"Mostra carte"** parses the IDs, looks up the card texts, and displays them in a randomized (shuffled) carousel to preserve player anonymity.
  - The Master picks the funniest completion, announces the winner, and taps **"Prossimo round"** to advance the game.
- **Player Turn**:
  - The player sees the question card with blanks (`________`) and a horizontal carousel of their 10 hand cards.
  - If the question requires 1 answer (`answerNeeded = 1`), clicking a card selects it.
  - If the question requires 2 answers (`answerNeeded = 2`), clicking the first highlights it and prompts for a second card.
  - The user is redirected to `CardPage`, displaying the completed sentence and the numeric card ID(s).
  - The player verbally speaks the card ID(s) to the Master.
  - Once the Master declares the winner, the player taps **"Ho vinto"** (Win: increments score and player rounds) or **"Ho perso"** (Loss: increments player rounds only).
  - The played cards are removed from the hand, replacement cards are drawn, and the app transitions to the next round (either another Player turn or a Master turn).

---

## 2. Target Architecture: BLoC & Clean Architecture

The project is undergoing refactoring from legacy state (`lib/old`) to the **BLoC pattern** following clean architecture layer boundaries:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│         (Pages, Widgets, BLoC Events & States)         │
└───────────────────────────┬────────────────────────────┘
                            │ depends on
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│             (Entities, Usecases, Contracts)            │
└───────────────────────────▲────────────────────────────┘
                            │ implemented by
┌───────────────────────────┴────────────────────────────┐
│                       Data Layer                       │
│    (Models, Data Sources, Repository Implementations)  │
└────────────────────────────────────────────────────────┘
```

### Layer Principles:
- **Presentation**: UI widgets dispatch `BlocEvent`s to a `Bloc` and rebuild using `BlocBuilder` or `BlocConsumer` based on emitted `BlocState`s. Presentation does not directly call data sources or manipulate seed logic.
- **Domain**: Pure business rules and contracts independent of Flutter UI and external libraries (except functional error handling via `fpdart` `Either`). Contains entity definitions and single-responsibility `UseCase` classes.
- **Data**: Implements domain repository contracts. Uses data providers (e.g., CSV reader) and data sources (local asset reader, PRNG card source) to fetch raw data and map it to domain entities via models.
- **Core**: Cross-cutting utilities, base use case abstractions, global error handling classes, app theme, and shared UI components.

### S.O.L.I.D. Principles in Code Structure

The refactored architecture strictly enforces the **S.O.L.I.D.** object-oriented design principles:

1. **Single Responsibility Principle (SRP)**:
   - Each class and file encapsulates exactly one responsibility and has one reason to change:
     - **Providers** (`CsvReader`) only read and parse file assets.
     - **Data Sources** (`LoadLocalDataSource`, `RandomQuestionsSource`) only provide typed models from their underlying store or PRNG.
     - **Repositories** (`LoadRepositoryImpl`, `GameRepositoryImpl`) only coordinate data sources, handle exceptions, and map data models into domain entities.
     - **Use Cases** (`LoadQuestions`, `DrawNextQuestion`, `RetriveAnswers`) encapsulate a single business action.
     - **BLoCs** (`LoadBloc`, `GameBloc`) only manage UI event-to-state transformations without embedding domain calculations or data fetching logic.

2. **Open/Closed Principle (OCP)**:
   - System modules are open for extension but closed for modification:
     - Domain foundations rely on polymorphic base abstractions: `CardAH`, `CardList<Card>`, `RandomCardSource<Card>`, and `UseCase<SuccessType>`.
     - Adding new card types, new game variations, or alternative data storage (e.g. remote HTTP backend or SQLite) requires creating new implementations of existing interfaces rather than modifying core domain entities or use cases.

3. **Liskov Substitution Principle (LSP)**:
   - Derived classes can substitute their base classes without breaking program correctness:
     - `Question` and `Answer` derive from `CardAH` and honor all base invariants.
     - `QuestionList` and `AnswerList` derive from `CardList<T>`.
     - Data models (`QuestionModel`, `AnswerModel`, `QuestionListModel`, `AnswerListModel`) inherit from their domain counterparts and can be substituted transparently across the repository layer.

4. **Interface Segregation Principle (ISP)**:
   - Clients depend only on small, focused, purpose-built interfaces rather than large monolithic contracts:
     - Distinct abstract repository contracts (`LoadRepository`, `GameRepository`) rather than a single bulky repository.
     - Segregated use case interfaces in core (`UseCase` vs `UseCaseParam`, synchronous vs `UseCaseAsync` / `UseCaseAsyncParam`).
     - Data sources expose dedicated contracts (`LoadLocalDataSource`, `RandomCardSource`) tailored solely to the data they supply.

5. **Dependency Inversion Principle (DIP)**:
   - High-level business modules (UseCases, BLoCs) never depend directly on low-level implementation details (CSV parsing, Flutter framework assets, specific `dart:math` PRNG instances). Both rely on abstractions (interfaces):
     - `LoadBloc` depends on abstract `LoadQuestions` and `LoadAnswers` use cases.
     - Use cases depend on the abstract `LoadRepository` and `GameRepository` interfaces.
     - Concrete repository implementations (`LoadRepositoryImpl`, `GameRepositoryImpl`) depend on abstract data source interfaces (`LoadLocalDataSource`, `RandomCardSource`).
     - All concrete dependencies are wired via constructor injection and managed centrally through the service locator (`GetIt` in [init_dependencies.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/init_dependencies.dart)).

---

## 3. Directory & File Scheme (`lib/`)

*(Excluding `lib/old`, which contains legacy UI components and the GitHub APK auto-updater).*

```
lib/
├── constants.dart
├── init_dependencies.dart
├── main.dart
│
├── core/
│   ├── entities/
│   │   └── data/
│   │       ├── card.dart
│   │       ├── card_list.dart
│   │       ├── question.dart
│   │       ├── question_list.dart
│   │       ├── answer.dart
│   │       └── answer_list.dart
│   ├── models/
│   │   ├── question_model.dart
│   │   ├── question_list_model.dart
│   │   ├── answer_model.dart
│   │   └── answer_list_model.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── theme/
│   │   └── theme.dart
│   ├── usecases/
│   │   ├── usecase.dart
│   │   └── usecase_param.dart
│   └── widgets/
│       └── textfield.dart
│
└── features/
    ├── load/
    │   ├── data/
    │   │   ├── datasource/
    │   │   │   └── local_datasource.dart
    │   │   ├── provider/
    │   │   │   └── csv_reader.dart
    │   │   └── repository/
    │   │       └── load_repository_impl.dart
    │   ├── domain/
    │   │   ├── repository/
    │   │   │   └── load_repository.dart
    │   │   └── usecases/
    │   │       ├── load_questions.dart
    │   │       └── load_answers.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── load_bloc.dart
    │       │   ├── load_event.dart
    │       │   └── load_state.dart
    │       └── page/
    │           └── start_page.dart
    │
    └── game/
        ├── data/
        │   ├── datasources/
        │   │   ├── rand_card_source.dart
        │   │   ├── rand_question_source.dart
        │   │   └── rand_answer_source.dart
        │   └── repository/
        │       └── game_repo_impl.dart
        ├── domain/
        │   ├── repository/
        │   │   └── game_repository.dart
        │   └── usecases/
        │       ├── draw_next_question.dart
        │       ├── draw_next_answer.dart
        │       └── retrive_answers.dart
        └── presentation/
            ├── bloc/
            │   ├── game_bloc.dart
            │   ├── game_data.dart
            │   ├── game_event.dart
            │   └── game_state.dart
            └── pages/
                ├── start_page.dart  (handled in features/load)
                ├── game_page.dart
                ├── card_page.dart
                └── master_page.dart
```

---

## 4. File-by-File Responsibility Breakdown

### Root Directory
- [constants.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/constants.dart): Application-wide constants including strings (name, UI instructions/hints in Italian), boundaries (`minPlayers = 3`, `maxPlayers = 20`), and rule parameters (`handLength = 10`).
- [init_dependencies.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/init_dependencies.dart): Dependency injection registry using `GetIt`. Registers data providers, data sources, repositories, use cases, and BLoC singletons.
- [main.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/main.dart): Application entry point. Invokes `initDependencies()`, sets up `MultiBlocProvider` (currently providing `LoadBloc`), sets `appTheme`, and boots to `StartPage`.

---

### Core Layer (`lib/core/`)

#### Entities (`lib/core/entities/data/`)
- [card.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/card.dart): `CardAH` abstract base entity defining card `id` and `text`.
- [card_list.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/card_list.dart): `CardList<Card>` generic container abstract class wrapping list operations (length, get, remove, add).
- [question.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/question.dart): `Question` entity extending `CardAH`, adding `answerNeeded` (1 or 2).
- [question_list.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/question_list.dart): `QuestionList` entity extending `CardList<Question>`.
- [answer.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/answer.dart): `Answer` entity extending `CardAH`.
- [answer_list.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/entities/data/answer_list.dart): `AnswerList` entity extending `CardList<Answer>`.

#### Shared Models (`lib/core/models/`)
- [question_model.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/models/question_model.dart): Data layer model representation of a question extending `Question`.
- [question_list_model.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/models/question_list_model.dart): Model extending `QuestionList`, providing `.fromList()` factory parser for CSV matrix rows.
- [answer_model.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/models/answer_model.dart): Data layer model representation of an answer extending `Answer`.
- [answer_list_model.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/models/answer_list_model.dart): Model extending `AnswerList`, providing `.fromStrings()` factory parser.

#### Error Handling (`lib/core/errors/`)
- [exceptions.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/errors/exceptions.dart): Defines runtime exceptions thrown by data providers and sources (e.g. `DataLoadException`).
- [failures.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/errors/failures.dart): Defines failure objects returned across repository/usecase boundaries (`Failure`, `DataFailure`, `DataRangeFailure`).

#### Theme & Widgets (`lib/core/theme/`, `lib/core/widgets/`)
- [theme.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/theme/theme.dart): App dark theme styling with orange color accents (`ColorScheme.dark`), transparent app bar, and rounded button themes.
- [textfield.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/textfield.dart): `CustomTextField` wrapper for `TextFormField` configured with `TextInputType.phone` (optimized for digits and dots `.`) and basic validation.

#### Use Cases Abstraction (`lib/core/usecases/`)
- [usecase.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/usecases/usecase.dart): Interfaces for parameterless operations: `UseCase<SuccessType>` (synchronous) and `UseCaseAsync<SuccessType>` (asynchronous).
- [usecase_param.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/usecases/usecase_param.dart): Interfaces for parameterized operations: `UseCaseParam<SuccessType, Param>` and `UseCaseAsyncParam<SuccessType, Param>`.

---

### Feature 1: Load (`lib/features/load/`)
Responsible for reading raw CSV cards from app assets on startup and making them available to the game.

#### Data Layer
- [csv_reader.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/data/provider/csv_reader.dart): Raw data provider reading `assets/csv/questions.csv` and `assets/csv/answers.csv` with semicolon delimiter via `csv` package.
- [local_datasource.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/data/datasource/local_datasource.dart): `LoadLocalDataSource` interface and `LoadLocalDataSourceImpl`. Translates raw CSV lists into `QuestionListModel` and `AnswerListModel`.
- [load_repository_impl.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/data/repository/load_repository_impl.dart): Implements `LoadRepository`. Catches `DataLoadException` and returns `Either<DataFailure, QuestionList>` / `AnswerList`.

#### Domain Layer
- [load_repository.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/domain/repository/load_repository.dart): Domain interface declaring `getQuestions()` and `getAnswers()`.
- [load_questions.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/domain/usecases/load_questions.dart): Usecase invoking repository to load question cards.
- [load_answers.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/domain/usecases/load_answers.dart): Usecase invoking repository to load answer cards.

#### Presentation Layer
- [load_bloc.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/presentation/bloc/load_bloc.dart): Handles `LoadQuestionsStart` and `LoadAnswersStart` events, emits `LoadInProgress`, `LoadQuestionsCompleted`, `LoadAnswersCompleted`, or error states.
- [load_event.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/presentation/bloc/load_event.dart): Sealed event hierarchy for card loading.
- [load_state.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/presentation/bloc/load_state.dart): Sealed state hierarchy for card loading.
- [start_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/presentation/page/start_page.dart): Entry screen where players input game seed, total players, and player number. Dispatches loading events to `LoadBloc`, listens for completed card lists, validates inputs, instantiates `GameManager`, and routes to `MasterGamePage` or `GamePage`.

---

### Feature 2: Game (`lib/features/game/`)
Responsible for game rounds, card drawing via PRNG, card selection, Master answer collection, and score management.

#### Data Layer
- [rand_card_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_card_source.dart): Interface `RandomCardSource<Card>` for drawing random cards, removing them, or getting cards by index.
- [rand_question_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_question_source.dart): `RandomQuestionsSource` implementation managing deterministic card draws from `QuestionListModel` using `Random(seed + 1)`.
- [rand_answer_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_answer_source.dart): `RandomAnswersSource` implementation managing answer selection and card skipping from `AnswerListModel` using `Random(seed)`.
- [game_repo_impl.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/repository/game_repo_impl.dart): Implements `GameRepository`. Bridges random card data sources with domain use cases.

#### Domain Layer
- [game_repository.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/repository/game_repository.dart): Interface defining operations `drawQuestionCard()`, `drawAnswerCard(totalPlayers, playerNumber)`, `drawAnswerCards(amount)`, and `retriveAnswers(ids)`.
- [draw_next_question.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/draw_next_question.dart): Use case to pull the current round's question card.
- [draw_next_answer.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/draw_next_answer.dart): Use case to pull player-specific answer card delegating directly to `drawAnswerCard` with deterministic card skipping.
- [retrive_answers.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/retrive_answers.dart): Use case to look up answer cards by their integer IDs.

#### Presentation Layer
- [game_bloc.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_bloc.dart): BLoC for game orchestration. Manages initial hand generation, round starts, multi-card click tracking (`FirstCardCliked`, `SecondCardCliked`), and answer card lookups (`AnswerCardsLoaded`).
- [game_data.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_data.dart): Singleton state holder for game round counters, score, active player hand, and Master turn rotation helper `isMasterForRound(round)`.
- [game_event.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_event.dart): Sealed game events (`StartRound`, `AnswerCardsRequested`, `CardClicked`, `RoundWon`, `RoundLost`).
- [game_state.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_state.dart): Sealed game states (`RoundStart`, `RoundReady`, `FirstCardCliked`, `SecondCardCliked`, `AnswerCardsLoaded`, `LoadFailure`).
- [game_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/game_page.dart): Normal player UI displaying current question, hand carousel, and card selection logic via `BlocConsumer<GameBloc, GameState>`.
- [card_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/card_page.dart): Displays the completed question with chosen answer(s) and card IDs from `GameBloc`, along with "Ho vinto" and "Ho perso" outcome buttons dispatching `RoundWon` / `RoundLost` and `StartRound`.
- [master_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/master_page.dart): Master UI displaying current question, text input for card IDs, and randomized card carousel for selecting the winner via `BlocConsumer<GameBloc, GameState>`.

---

## 5. Current Refactoring State & Known Technical Debt

To facilitate subsequent refactoring steps, be aware of the following transitional state:

1. **GameBloc Registration & Presentation Provider Integration [RESOLVED]**:
   - `initGameDependencies()` in `init_dependencies.dart` dynamically registers `GameBloc`, `GameRepository`, use cases, and PRNG card data sources in `GetIt` when a match begins on `StartPage`.
   - Connected `GameBloc` across presentation routes (`StartPage`, `GamePage`, `CardPage`, `MasterGamePage`) via `BlocProvider.value`, dispatching `StartRound`, `RoundWon`, `RoundLost`, and `AnswerCardsRequested`.
2. **Duplicated Models in `load` and `game` [RESOLVED]**:
   - Consolidated into shared models in `lib/core/models/` (`question_model.dart`, `question_list_model.dart`, `answer_model.dart`, `answer_list_model.dart`). The redundant feature-local model folders were deleted.
3. **Card Lookup Index Bug in `GameRepositoryImpl` [RESOLVED]**:
   - Fixed in `lib/features/game/data/repository/game_repo_impl.dart`: `randAnswersSource.getCardAt(ids[index])` properly accesses the passed card ID instead of the loop index.
4. **Seed Stride Synchronization & GameManager Elimination [RESOLVED]**:
   - Synchronized PRNG seed stride across devices via `getRandomCardWithSkip()` in `RandomAnswersSource`. `GameManager` and `lib/core/gamelogic/logic.dart` have been completely removed.
5. **Seed Offset in RandomQuestionsSource [RESOLVED]**:
   - Fixed in `features/game/data/datasources/rand_question_source.dart`: `Random(seed + 1)` is used for question PRNG sequencing. Renamed internal field `_answerList` to `_questionList`.
6. **Interleaved Drawing & Card Skipping in RandomAnswersSource [RESOLVED]**:
   - Implemented `skipCards(amount)` and `getRandomCardWithSkip(totalPlayers, playerNumber)` in `features/game/data/datasources/rand_answer_source.dart` to advance the PRNG stream deterministically and deal player-specific cards.
7. **GameManager Removal & Full Presentation BLoC Integration [RESOLVED]**:
   - Fully eliminated `GameManager` and deleted `lib/core/gamelogic/logic.dart`.
   - Decoupled `CardAHW` in `lib/old/view/components/card.dart` from global static selection state; it now receives `isSelected` and invokes `onClicked` callbacks.
   - Refactored `GamePage`, `CardPage`, `MasterGamePage`, and `StartPage` to use `GameBloc`, `BlocConsumer`, and `GameState` for round starts, hand rendering, card selection, Master answer collection, and winner declarations.
8. **Legacy UI Widget Dependencies [OPEN]**:
   - The game presentation pages still import `CardAHW`, `CustomAppBar`, `CustomButton`, and `GameInfo` from `lib/old/view/components/`. Migrating these into modern widgets or `lib/core/widgets/` is part of the refactoring roadmap.
