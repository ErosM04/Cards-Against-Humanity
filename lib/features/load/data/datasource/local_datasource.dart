import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/features/load/data/models/answer_list_model.dart';
import 'package:cards_against_humanity/features/load/data/models/question_list_model.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';

/// Interface that declares the methods that the data layer has to provide.
abstract interface class LoadLocalDataSource {
  /// Returns a model containing the list of questions.
  Future<QuestionListModel> getQuestions();

  /// Returns a model containing the list of answers.
  Future<AnswerListModel> getAnswers();
}

/// Implementation of ``[LoadLocalDataSource]`` that defines the main methods the data layer has to provide.
class LoadLocalDataSourceImpl implements LoadLocalDataSource {
  /// Object used to read csv file in assets.
  final CsvReader csvReader;

  const LoadLocalDataSourceImpl({required this.csvReader});

  @override
  Future<QuestionListModel> getQuestions() async {
    try {
      return QuestionListModel.fromList(
        list: (await csvReader.getQuestions()) as List<List<String>>,
      );
    } catch (e) {
      throw DataLoadException(e.toString());
    }
  }

  @override
  Future<AnswerListModel> getAnswers() async {
    try {
      final list = await csvReader.getAnswers();
      List<String> answers = [];

      for (var answer in list) {
        answers.add(answer[0]);
      }

      return AnswerListModel.fromList(list: answers);
    } catch (e) {
      throw DataLoadException(e.toString());
    }
  }
}
