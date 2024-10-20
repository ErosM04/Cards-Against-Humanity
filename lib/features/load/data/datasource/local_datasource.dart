import 'package:cards_against_humanity/core/error/exceptions.dart';
import 'package:cards_against_humanity/features/load/data/models/answer_list_model.dart';
import 'package:cards_against_humanity/features/load/data/models/question_list_model.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';

abstract interface class LoadLocalDataSource {
  Future<QuestionListModel> getQuestions();
  Future<AnswerListModel> getAnswers();
}

class LoadLocalDataSourceImpl implements LoadLocalDataSource {
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

      return AnswerListModel(list: answers);
    } catch (e) {
      throw DataLoadException(e.toString());
    }
  }
}
