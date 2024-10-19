import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'load_event.dart';
part 'load_state.dart';

class LoadBloc extends Bloc<LoadEvent, LoadState> {
  final LoadQuestions _loadQuestions;
  final LoadAnswers _loadAnswers;

  LoadBloc({
    required LoadQuestions loadQuestions,
    required LoadAnswers loadAnswers,
  })  : _loadQuestions = loadQuestions,
        _loadAnswers = loadAnswers,
        super(LoadInitial()) {
    on<LoadStart>(
      (event, emit) async {
        List<List<String>> questions = [];
        List<String> answers = [];

        emit(LoadInProgress());

        final questionsRes = await _loadQuestions();
        final answersRes = await _loadAnswers();

        questionsRes.fold(
          (l) => emit(LoadQuestionsFailure(l.message)),
          (r) => questions = r,
        );
        answersRes.fold(
          (l) => emit(LoadAnswersFailure(l.message)),
          (r) => answers = r,
        );

        if (questions.isNotEmpty && answers.isNotEmpty) {
          emit(LoadCompleted(questions: questions, answers: answers));
        }
      },
    );
  }
}
