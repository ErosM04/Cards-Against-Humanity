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
  - The Master inputs the IDs separated by `.`, `,`, or `-`, e.g.:
    - Single-answer question: `96.445.237` (or `96,445,237` / `96-445-237`)
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
│       ├── appbar.dart
│       ├── button.dart
│       ├── card.dart
│       ├── info.dart
│       ├── snackbar.dart
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
    ├── game/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── rand_card_source.dart
    │   │   │   ├── rand_question_source.dart
    │   │   │   └── rand_answer_source.dart
    │   │   └── repository/
    │   │       └── game_repo_impl.dart
    │   ├── domain/
    │   │   ├── repository/
    │   │   │   └── game_repository.dart
    │   │   └── usecases/
    │   │       ├── draw_next_question.dart
    │   │       ├── draw_next_answer.dart
    │   │       └── retrive_answers.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── game_bloc.dart
    │       │   ├── game_data.dart
    │       │   ├── game_event.dart
    │       │   └── game_state.dart
    │       └── pages/
    │           ├── start_page.dart  (handled in features/load)
    │           ├── game_page.dart
    │           ├── card_page.dart
    │           └── master_page.dart
    │
    └── update/
        ├── data/
        │   ├── datasources/
        │   │   ├── update_local_datasource.dart
        │   │   └── update_remote_datasource.dart
        │   ├── models/
        │   │   └── app_release_model.dart
        │   └── repository/
        │       └── update_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── app_release.dart
        │   │   └── app_version.dart
        │   ├── repository/
        │   │   └── update_repository.dart
    │       └── usecases/
    │           ├── check_for_update.dart
    │           ├── clear_cached_updates.dart
    │           ├── download_apk.dart
    │           ├── install_apk.dart
    │           └── manage_update_permission.dart
        └── presentation/
            ├── bloc/
            │   ├── update_bloc.dart
            │   ├── update_event.dart
            │   └── update_state.dart
            └── widgets/
                ├── app_alert_dialog.dart
                ├── download_progress_dialog.dart
                ├── install_error_dialog.dart
                ├── release_section_box.dart
                ├── update_dialog.dart
                ├── update_listener.dart
                └── update_prompt_dialog.dart
```

---

## 4. File-by-File Responsibility Breakdown

### Root Directory
- [constants.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/constants.dart): Application-wide constants including strings (name, UI instructions/hints in Italian), boundaries (`minPlayers = 3`, `maxPlayers = 20`), rule parameters (`handLength = 10`), and release/update endpoints (`appVersion`, `githubLatestReleaseUrl`, `githubReleasesPageUrl`, `githubLatestApkUrl`).
- [init_dependencies.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/init_dependencies.dart): Dependency injection registry using `GetIt`. Registers data providers, data sources, repositories, use cases, and BLoC singletons (`LoadBloc`, `UpdateBloc`, and session-scoped `GameBloc`).
- [main.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/main.dart): Application entry point. Invokes `initDependencies()`, sets up `MultiBlocProvider` (providing `LoadBloc` and `UpdateBloc`), sets `appTheme`, and boots to `StartPage`.

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
- [exceptions.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/errors/exceptions.dart): Defines runtime exceptions thrown by data providers, sources, and parsers (`DataLoadException`, `UpdateException`, `VersionParseException`).
- [failures.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/errors/failures.dart): Defines failure objects returned across repository/usecase boundaries (`Failure`, `DataFailure`, `DataRangeFailure`).

#### Theme & Widgets (`lib/core/theme/`, `lib/core/widgets/`)
- [theme.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/theme/theme.dart): App dark theme styling with orange color accents (`ColorScheme.dark`), transparent app bar, and rounded button themes using `material_ui`.
- [appbar.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/appbar.dart): `CustomAppBar` lightweight `StatelessWidget` implementing `PreferredSizeWidget` displaying app title and dynamic score/rounds counter.
- [button.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/button.dart): `CustomButton` styled `ElevatedButton` wrapper with typed `VoidCallback onPressed` and preset typography and padding.
- [card.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/card.dart): `CardAHW` question and answer card widget supporting selection highlights, text scroll, and inline blank replacement.
- [info.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/info.dart): `GameInfo` popup widget displaying contextual information tooltips via `InfoPopupWidget`.
- [snackbar.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/snackbar.dart): `showCustomSnackBar` shared floating rounded SnackBar sized dynamically to message length, font size/text scaler, and screen-responsive minimum dimensions.
- [textfield.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/core/widgets/textfield.dart): `CustomTextField` detached white-bordered input box wrapping `FormField`/`TextField` configured with `TextInputType.phone`, non-empty guard, custom `validator` hook, and external `errorText` support.

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
- [start_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/load/presentation/page/start_page.dart): Entry screen where players input game seed, total players, and player number. Accepts `checkForUpdate` and `showExplicitContentWarning` flags (enabled on app boot in [main.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/main.dart), `false` by default when returning from a game), dispatches loading events to `LoadBloc`, listens for completed card lists, validates inputs, initializes `GameBloc`, and routes to `MasterGamePage` or `GamePage`.

---

### Feature 2: Game (`lib/features/game/`)
Responsible for game rounds, card drawing via PRNG, card selection, Master answer collection, and score management.

#### Data Layer
- [rand_card_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_card_source.dart): Interface `RandomCardSource<Card>` for drawing random cards, removing them, or getting cards by index.
- [rand_question_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_question_source.dart): `RandomQuestionsSource` implementation managing deterministic card draws from `QuestionListModel` using `Random(seed + 1)`.
- [rand_answer_source.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/datasources/rand_answer_source.dart): `RandomAnswersSource` implementation managing per-player deterministic answer selection and card skipping from `AnswerListModel` using `Random(seed)`.
- [game_repo_impl.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/data/repository/game_repo_impl.dart): Implements `GameRepository`. Bridges random card data sources with domain use cases.

#### Domain Layer
- [game_repository.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/repository/game_repository.dart): Interface defining operations `drawQuestionCard()`, `drawAnswerCard(totalPlayers, playerNumber)`, `drawAnswerCards(amount)`, and `retriveAnswers(ids)`.
- [draw_next_question.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/draw_next_question.dart): Use case to pull the current round's question card.
- [draw_next_answer.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/draw_next_answer.dart): Use case to pull player-specific answer card delegating directly to `drawAnswerCard` with deterministic card skipping.
- [retrive_answers.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/domain/usecases/retrive_answers.dart): Use case validating submitted Master answer IDs against `eligibleIds` via `RetriveAnswersParams` and fetching matching `AnswerList`.

#### Presentation Layer
- [game_bloc.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_bloc.dart): BLoC for game orchestration. Manages initial hands and tracked other-player eligible IDs, round refills, multi-card click tracking (`FirstCardCliked`, `SecondCardCliked`), and validated answer card lookups (`AnswerCardsLoaded` / `LoadFailure`).
- [game_data.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_data.dart): Singleton state holder for game round counters, score, active player hand, tracked `otherPlayersCardIds`, and Master turn rotation helpers (`masterForRound`, `isMasterRound`).
- [game_event.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_event.dart): Sealed game events (`StartRound`, `AnswerCardsRequested`, `CardClicked`, `RoundWon`, `RoundLost`).
- [game_state.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/bloc/game_state.dart): Sealed game states (`RoundStart`, `RoundReady`, `FirstCardCliked`, `SecondCardCliked`, `AnswerCardsLoaded`, `LoadFailure`).
- [game_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/game_page.dart): Normal player UI displaying current question, hand carousel, and card selection logic via `BlocConsumer<GameBloc, GameState>`.
- [card_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/card_page.dart): Displays the completed question with chosen answer(s) and card IDs from `GameBloc`, along with "Ho vinto" and "Ho perso" outcome buttons dispatching `RoundWon` / `RoundLost` and `StartRound`.
- [master_page.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/game/presentation/pages/master_page.dart): Master UI displaying current question, validated text input for card IDs, inline field error feedback on syntax errors or `LoadFailure`, and randomized card carousel for selecting the winner via `BlocConsumer<GameBloc, GameState>`.

---

### Feature 3: Update (`lib/features/update/`)
Responsible for clearing cached update APKs on startup, checking GitHub Releases for newer app versions, prompting the user, requesting Android install permission, downloading the APK into private internal cache with live progress, launching package installation, and offering retry or browser download if installation fails.

#### Data Layer
- [app_release_model.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/data/models/app_release_model.dart): `AppReleaseModel` extending `AppRelease` with `.fromJson()` deserialization for GitHub's latest release JSON payload.
- [update_remote_datasource.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/data/datasources/update_remote_datasource.dart): `UpdateRemoteDataSource` interface and `UpdateRemoteDataSourceImpl` fetching release metadata via `http.Client` and streaming APK downloads via `Dio` with progress callbacks and partial-file cleanup on failure.
- [update_local_datasource.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/data/datasources/update_local_datasource.dart): `UpdateLocalDataSource` interface and `UpdateLocalDataSourceImpl` handling app-internal `updates/` path resolution (`getTemporaryDirectory()` with fallback to `getApplicationSupportDirectory()` and `getExternalStorageDirectory()`), cache cleanup, `permission_handler` checks/requests (`requestInstallPackages`), and `OpenFilex.open()` APK launching.
- [update_repository_impl.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/data/repository/update_repository_impl.dart): Implements `UpdateRepository`. Compares release version/draft flags against `appVersion`, coordinates remote/local datasources, and maps exceptions/installer failures into `Either<Failure, ...>` (`UpdateInstallFailure`, `UpdatePermissionFailure`, `Failure`).

#### Domain Layer
- [app_version.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/entities/app_version.dart): `AppVersion` value entity parsing `<major>.<minor>.<patch>[-info]` (splitting on the first two `.` characters and stripping the leading `-`, throwing `VersionParseException` on failure) and implementing `==`, `<`, `>`, `<=`, `>=`, and `Comparable<AppVersion>`.
- [app_release.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/entities/app_release.dart): `AppRelease` domain entity holding typed `AppVersion`, changelog body, draft status, download URL, and release URL.
- [update_repository.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/repository/update_repository.dart): Domain contract (`UpdateRepository`) and `UpdatePermission` enum (`installPackages`).
- [check_for_update.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/usecases/check_for_update.dart): Use case checking whether a newer non-draft release exists.
- [clear_cached_updates.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/usecases/clear_cached_updates.dart): Use case deleting previously downloaded APK files from internal cache/fallback folders.
- [download_apk.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/usecases/download_apk.dart): Use case downloading the release APK with progress callback via `DownloadApkParams`.
- [install_apk.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/usecases/install_apk.dart): Use case launching the OS package installer for a downloaded APK path.
- [manage_update_permission.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/domain/usecases/manage_update_permission.dart): Use case checking and requesting `UpdatePermission` grants.

#### Presentation Layer
- [update_bloc.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/bloc/update_bloc.dart): `UpdateBloc` orchestrating startup cache cleanup, release checks, download progress emissions, install permission prompts, automatic install handoff, and cleanup on decline/failure.
- [update_event.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/bloc/update_event.dart): Sealed events (`UpdateCacheClearRequested`, `UpdateCheckRequested`, `UpdateDeclined`, `UpdateDownloadRequested`, `UpdateInstallRequested`).
- [update_state.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/bloc/update_state.dart): Sealed states (`UpdateInitial`, `UpdateUpToDate`, `UpdateAvailable`, `UpdateDownloadInProgress`, `UpdateDownloadCompleted`, `UpdateDownloadFailed`, `UpdateInstallCompleted`, `UpdateInstallFailed`, `UpdateNotice`).
- [app_alert_dialog.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/app_alert_dialog.dart): Shared animated confirmation dialog (`AppAlertDialog`) with scrollable content area and accent-colored headers.
- [release_section_box.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/release_section_box.dart): `ReleaseSectionBox` detached, bordered scrollable box rendering a release-note section.
- [update_prompt_dialog.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/update_prompt_dialog.dart): `UpdatePromptDialog` parsing release sections and rendering scrollable `ReleaseSectionBox` lists.
- [download_progress_dialog.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/download_progress_dialog.dart): `DownloadProgressDialog` showing live APK download progress via `BlocBuilder<UpdateBloc, UpdateState>`.
- [install_error_dialog.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/install_error_dialog.dart): `InstallErrorDialog` presenting installer errors with `"Riprova"` and `"Scarica dal browser"` actions.
- [update_dialog.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/update_dialog.dart): Barrel export re-exporting all update dialog widgets.
- [update_listener.dart](file:///C:/Users/erosm/Desktop/Cards-Against-Humanity/lib/features/update/presentation/widgets/update_listener.dart): `UpdateListener` wrapping `StartPage` to present animated update/error dialogs, launch external browser fallback downloads, show live download modals, and present dynamically sized SnackBars via `showCustomSnackBar` without leaking `BuildContext` into BLoC.
