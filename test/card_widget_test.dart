import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:cards_against_humanity/core/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Runs widget tests verifying [CardAHW] border colors and detached shadows.
void main() {
  testWidgets('CardAHW preserves white/orange borders and applies detached shadow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: Column(
            children: [
              CardAHW(text: 'Domanda', isMainCard: true, isClickable: false),
              CardAHW(text: 'Risposta'),
              CardAHW(text: 'Selezionata', isSelected: true),
            ],
          ),
        ),
      ),
    );

    BoxDecoration decorationOf(String label) {
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      return container.decoration! as BoxDecoration;
    }

    final mainDec = decorationOf('Domanda');
    final answerDec = decorationOf('Risposta');
    final selectedDec = decorationOf('Selezionata');

    expect(
      (mainDec.border! as Border).top.color,
      equals(appTheme.colorScheme.primary),
    );
    expect((answerDec.border! as Border).top.color, equals(Colors.white));
    expect(
      (selectedDec.border! as Border).top.color,
      equals(appTheme.colorScheme.secondary),
    );
    expect(mainDec.boxShadow, isNotEmpty);
    expect(answerDec.boxShadow, isNotEmpty);
  });

  testWidgets('CardAHW renders ________ question blanks as straight-line WidgetSpans',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: CardAHW(
            text: '________ è meglio di ________ .',
            isMainCard: true,
            isClickable: false,
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    final rootSpan = textWidget.textSpan! as TextSpan;
    final widgetSpans = rootSpan.children!.whereType<WidgetSpan>().toList();

    expect(widgetSpans, hasLength(2));
    final blankBoxes = find.descendant(
      of: find.byType(RichText),
      matching: find.byType(Container),
    );
    expect(blankBoxes, findsNWidgets(2));
    expect(tester.getSize(blankBoxes.first), equals(const Size(85.0, 2.0)));
    expect(find.textContaining('________', findRichText: true), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: CardAHW(
            text: 'Test ________ .',
            isMainCard: false,
            isClickable: false,
          ),
        ),
      ),
    );

    final smallBox = find.descendant(
      of: find.byType(RichText),
      matching: find.byType(Container),
    );
    expect(tester.getSize(smallBox).width, closeTo(17.0 * 4.25, 0.01));
    expect(tester.getSize(smallBox).height, closeTo(17.0 * 0.1, 0.01));
  });
}
