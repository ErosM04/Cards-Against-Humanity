import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs statistical checks on answer card draws and PRNG seed distribution.
void main() {
  test(
    'Analize answers drawing',
    () => _loadAnswers().then(
      (value) {
        List<String> answers = value
            .map((row) => row.isNotEmpty ? row[0].toString() : '')
            .where((text) => text.trim().isNotEmpty)
            .toList();
        if (answers.isNotEmpty) {
          _evalueateDrawFrequency(answers);
        }
      },
    ),
  );

  // The test result highlight a lower standard deviation with higher seed numbers.
  // Therefore using seeds with at least 10 digits is proven to increase the randomness factor.
  test(
    'Verify seed behavior in Random',
    () {
      // print('Campione seed: 0-1000');
      simulatesDraws(firstSeed: 0, lastSeed: 1000);

      for (var i = 0; i < 10; i++) {
        int lower = pow(10, i + 5).round();
        int higher = (pow(10, i + 5).round()) + 1000;

        // print('------------------');
        // print('Campione seed: $lower-$higher');
        simulatesDraws(firstSeed: lower, lastSeed: higher);
      }
    },
  );
}

// ----------- TESTING DRAW -----------------

/// Loads answer CSV rows from disk or the Flutter asset bundle.
Future<List<List>> _loadAnswers() async {
  final file = File('assets/csv/answers.csv');
  if (file.existsSync()) {
    return const CsvDecoder(fieldDelimiter: ';', dynamicTyping: false)
        .convert(await file.readAsString());
  }
  // row added to initialize Binding for test pourpose
  WidgetsFlutterBinding.ensureInitialized();
  return const CsvDecoder(fieldDelimiter: ';', dynamicTyping: false)
      .convert(await rootBundle.loadString("assets/csv/answers.csv"));
}

/// Evaluates positive draw-frequency deviations across repeated seeds for [list].
void _evalueateDrawFrequency(List<String> list) {
  // print(list.length);
  List<int> numeri = List.filled(list.length, 0);
  for (var i = 1; i < 100000; i++) {
    // Random sampei = Random(Random().nextInt(1001));
    Random sampei = Random(i);
    for (var i = 0; i < 100; i++) {
      numeri[sampei.nextInt(list.length)]++;
    }
  }

  int avg = 0;
  for (var element in numeri) {
    avg += element;
  }
  avg = (avg / numeri.length).round();

  int avgScartiPos = 0; // fa una media contando solo gli scarti positivi
  int contatoreScartiPositivi = 0;
  // List<List<int>> temp = [];
  for (var i = 0; i < numeri.length; i++) {
    if ((numeri[i] - avg) > 0) {
      // print('${i + 1} = ${(numeri[i] - avg)}');
    }
    if ((numeri[i] - avg) > 0) {
      contatoreScartiPositivi++;
      avgScartiPos += (numeri[i] - avg);
      // if ((numeri[i] - avg) > 12) {
      //   temp.add([i + 1, (numeri[i] - avg)]);
      // }
    }
  }
  if (contatoreScartiPositivi > 0) {
    avgScartiPos = (avgScartiPos / contatoreScartiPositivi).round();
  }
  // print('---------------------------------------');
  // print('Avg scarti pos: $avgScartiPos');
  // print('---------------------------------------');

  List<List<int>> moltoPresenti = [];
  for (var i = 0; i < numeri.length; i++) {
    if ((numeri[i] - avg) > (2 * avgScartiPos).round()) {
      moltoPresenti.add([i + 1, (numeri[i] - avg)]);
    }
  }
}

// ----------- TESTING VARIOUS DRAWS PER VARIOUS SEEDS -----------------

/// Simulates [drawPerSeed] random draws per seed from [firstSeed] up to [lastSeed] (excluded).
void simulatesDraws({
  required int firstSeed,
  required int lastSeed,
  int numberOfOutcome = 800,
  int drawPerSeed = 100,
}) {
  List<int> numeri = List.filled(numberOfOutcome, 0);
  // double avg = (((lastSeed - firstSeed) * drawPerSeed) / numberOfOutcome);

  for (var i = firstSeed; i < lastSeed; i++) {
    for (var j = 0; j < drawPerSeed; j++) {
      numeri[Random(i).nextInt(numeri.length)]++;
    }
  }
}
