import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class CsvReader {
  const CsvReader();

  Future<List<List>> getQuestions() async => await _loadCSV('question');

  Future<List<String>> getAnswers() async {
    final list = await _loadCSV('answers');
    List<String> answers = [];

    for (var answer in list) {
      answers.add(answer[0]);
    }

    return answers;
  }

  Future<List<List>> _loadCSV(String filename) async =>
      const CsvToListConverter().convert(
          await rootBundle.loadString("assets/csv/$filename.csv"),
          fieldDelimiter: ';');
}
