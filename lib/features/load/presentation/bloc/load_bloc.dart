import 'dart:async';
import 'package:cards_against_humanity/features/load/domain/entities/answer_list.dart';
import 'package:cards_against_humanity/features/load/domain/entities/question_list.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'load_event.dart';
part 'load_state.dart';

/// Manages the retrival of **cards related data** from the app'assets.
///
/// Through its events provides a list of questions and a list of answer, based on the content of the card of
/// Cards Against Humanity.
class LoadBloc extends Bloc<LoadEvent, LoadState> {
  final LoadQuestions _loadQuestions;
  final LoadAnswers _loadAnswers;

  LoadBloc({
    required LoadQuestions loadQuestions,
    required LoadAnswers loadAnswers,
  })  : _loadQuestions = loadQuestions,
        _loadAnswers = loadAnswers,
        super(LoadInitial()) {
    on<LoadQuestionsStart>(_loadQuestionsStart);
    on<LoadAnswersStart>(loadAnswersStart);
  }

  /// Immediatly sets the state as [LoadInProgress] and then proceeds to use [_loadQuestions] to load the
  /// response, than `fold` method is used to either emit a [LoadQuestionsFailure] or a [LoadQuestionsCompleted],
  /// which takes the [QuestionList] of the result, containg the question cards content.
  FutureOr<void> _loadQuestionsStart(event, emit) async {
    emit(LoadInProgress());

    final questionsRes = await _loadQuestions();

    questionsRes.fold(
      (fail) => emit(LoadQuestionsFailure(fail.message)),
      (qst) => emit(LoadQuestionsCompleted(questions: qst)),
    );
  }

  /// Immediatly sets the state as [LoadInProgress] and then proceeds to use [_loadAnswers] to load the
  /// response, than `fold` method is used to either emit a [LoadAnswersFailure] or a [LoadAnswersCompleted],
  /// which takes the [AnswerList] of the result, containg the answer cards content.
  FutureOr<void> loadAnswersStart(event, emit) async {
    emit(LoadInProgress());

    final answersRes = await _loadAnswers();

    answersRes.fold(
      (fail) => emit(LoadAnswersFailure(fail.message)),
      (asw) => emit(LoadAnswersCompleted(answers: asw)),
    );
  }
}
