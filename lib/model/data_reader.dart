import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// Used to access to assets's csv files and convert them.
class CsvReader {
  const CsvReader();

  /// Uses the method ``[_loadCSV]`` to load the questions from a file in the assets.
  ///
  /// #### Returns
  /// ``Future<List<String>>`` : a list of list, where each list contains two elements, the question and the amount of answers needed.
  Future<List<List>> getQuestions() async => await _loadCSV('questions');

  /// Uses the method ``[_loadCSV]`` to load the answers from a file in the assets.
  ///
  /// #### Returns
  /// ``Future<List<String>>`` : the list of answers.
  Future<List<String>> getAnswers() async {
    final list = await _loadCSV('answers');
    List<String> answers = [];

    for (var answer in list) {
      answers.add(answer[0]);
    }

    return answers;
  }

  /// Uses the ``[CsvToListConverter]`` object and the method ``convert()`` to convert the string of the specified file into a csv.
  /// #### Parameters
  /// - ``String [filename]`` : the name of the csv file, without the extension.
  ///
  /// #### Returns
  /// ``Future<List<List>>`` : the list of row, each cell is a row and is a list itself; each item of the row list is a cell of the csv file.
  Future<List<List>> _loadCSV(String filename) async =>
      const CsvToListConverter().convert(
        await rootBundle.loadString("assets/csv/$filename.csv"),
        fieldDelimiter: ';',
      );
}
