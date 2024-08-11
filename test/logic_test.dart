import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Analize answers drawing',
    () => _ciapa().then(
      (value) {
        // print((value[0][0] as String).length);
        List<String> answers = [];
        for (var answer in (value[0][0] as String).split('\n')) {
          answers.add(answer);
        }
        // print(answers);
        _salame(answers);
      },
    ),
  );

  // The test result highlight a lower standard deviation with higher seed numbers.
  // Therefore using seeds with at least 10 digits is proven to increase the randomness factor.
  test(
    'Verify seed behavior in Random',
    () {
      print('Campione seed: 0-1000');
      lerciume(firstSeed: 0, lastSeed: 1000);

      for (var i = 0; i < 10; i++) {
        int lower = pow(10, i + 5).round();
        int higher = (pow(10, i + 5).round()) + 1000;

        print('------------------');
        print('Campione seed: $lower-$higher');
        lerciume(firstSeed: lower, lastSeed: higher);
      }
    },
  );
}

// ----------- TESTING DRAW -----------------

Future<List<List>> _ciapa() async {
  // row added to initialize Binding for test pourpose
  WidgetsFlutterBinding.ensureInitialized();
  return const CsvToListConverter().convert(
      await rootBundle.loadString("assets/csv/answers.csv"),
      fieldDelimiter: ';',
      shouldParseNumbers: false);
}

void _salame(List<String> list) {
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
      print('${i + 1} = ${(numeri[i] - avg)}');
    }
    if ((numeri[i] - avg) > 0) {
      contatoreScartiPositivi++;
      avgScartiPos += (numeri[i] - avg);
      // if ((numeri[i] - avg) > 12) {
      //   temp.add([i + 1, (numeri[i] - avg)]);
      // }
    }
  }
  avgScartiPos = (avgScartiPos / contatoreScartiPositivi).round();
  print('---------------------------------------');
  print('Avg scarti pos: $avgScartiPos');
  print('---------------------------------------');

  List<List<int>> moltoPresenti = [];
  for (var i = 0; i < numeri.length; i++) {
    if ((numeri[i] - avg) > (2 * avgScartiPos).round()) {
      moltoPresenti.add([i + 1, (numeri[i] - avg)]);
    }
  }
  for (var element in moltoPresenti) {
    print(
        'Pos: ${element[0]} - Occ: ${element[1]} -\tFrase: ${list[element[0] - 1]}');
  }
  print('tot: ${moltoPresenti.length}');
}

// ----------- TESTING RANDOM CON SBORRA (SEED) -----------------

void lerciume({
  required int firstSeed,
  required int lastSeed,
  int numberOfOutcome = 800,
  int drawPerSeed = 100,
}) {
  List<int> numeri = List.filled(numberOfOutcome, 0);
  double avg = (((lastSeed - firstSeed) * drawPerSeed) / numberOfOutcome);

  for (var i = firstSeed; i < lastSeed; i++) {
    for (var j = 0; j < drawPerSeed; j++) {
      numeri[Random(i).nextInt(numeri.length)]++;
    }
  }

  // for (var i = 0; i < numeri.length; i++) {
  //   print('${i + 1} : ${numeri[i]}');
  // }

  double deviazStd = 0;
  for (var element in numeri) {
    deviazStd += pow(element - avg, 2);
  }

  print('varianza: ${(deviazStd / lastSeed).toStringAsFixed(2)}');
  print('sqm: ${sqrt(deviazStd / lastSeed).toStringAsFixed(2)}');
}
