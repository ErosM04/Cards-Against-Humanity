import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CsvDecoder parses question rows with semicolon delimiter and dynamic typing', () {
    const raw = '________ : testato dai bambini.;1\n________ . Perfetto per ________ !;2\n';
    final rows = const CsvDecoder(fieldDelimiter: ';', dynamicTyping: true).convert(raw);

    expect(rows.length, equals(2));
    expect(rows[0][0], equals('________ : testato dai bambini.'));
    expect(rows[0][1], equals(1));
    expect(rows[1][0], equals('________ . Perfetto per ________ !'));
    expect(rows[1][1], equals(2));

    final model = QuestionListModel.fromList(list: rows);
    expect(model.length, equals(2));
    expect(model.getCardAt(0).text, equals('________ : testato dai bambini.'));
    expect(model.getCardAt(0).answerNeeded, equals(1));
    expect(model.getCardAt(1).answerNeeded, equals(2));
  });

  test('CsvDecoder parses answer rows without delimiter', () {
    const raw = 'Twittare\n72 vergini\nAbbuffarsi e vomitare\n';
    final rows = const CsvDecoder(fieldDelimiter: ';', dynamicTyping: true).convert(raw);

    expect(rows.length, equals(3));
    expect(rows[0][0], equals('Twittare'));
    expect(rows[1][0], equals('72 vergini'));
    expect(rows[2][0], equals('Abbuffarsi e vomitare'));

    final answers = rows.map((r) => r[0].toString()).toList();
    final model = AnswerListModel.fromStrings(list: answers);
    expect(model.length, equals(3));
    expect(model.getCardAt(0).text, equals('Twittare'));
    expect(model.getCardAt(1).text, equals('72 vergini'));
  });
}
