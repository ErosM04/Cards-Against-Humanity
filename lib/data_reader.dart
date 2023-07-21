import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class CsvReader {
  const CsvReader();

  Future<List<List>> getQuestions() async => await _loadCSV('question');

  getAnswers() async {
    final List list = await _loadCSV('answers');
    list.forEach((element) => print(element));
  }

  Future<List<List>> _loadCSV(String filename) async =>
      const CsvToListConverter().convert(
          await rootBundle.loadString("assets/$filename.csv"),
          fieldDelimiter: ';');
}
