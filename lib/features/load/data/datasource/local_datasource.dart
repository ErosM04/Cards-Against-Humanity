import 'package:cards_against_humanity/core/error/exceptions.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';

abstract interface class LoadLocalDataSource {
  Future<List<List<String>>> getQuestions();

  Future<List<String>> getAnswers();
}

class LoadLocalDataSourceImpl implements LoadLocalDataSource {
  final CsvReader csvReader;

  const LoadLocalDataSourceImpl({required this.csvReader});

  @override
  Future<List<String>> getAnswers() async {
    try {
      final list = await csvReader.getAnswers();
      List<String> answers = [];

      for (var answer in list) {
        answers.add(answer[0]);
      }

      return answers;
    } catch (e) {
      throw DataLoadException(e.toString());
    }
  }

  @override
  Future<List<List<String>>> getQuestions() async {
    try {
      return await csvReader.getQuestions() as List<List<String>>;
    } catch (e) {
      throw DataLoadException(e.toString());
    }
  }
}
