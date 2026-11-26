import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Runs widget tests verifying [CustomButton] width scaling and press callbacks.
void main() {
  testWidgets('CustomButton adapts horizontal width to text length',
      (tester) async {
    bool tappedShort = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  text: 'No',
                  onPressed: () => tappedShort = true,
                ),
                CustomButton(
                  text: 'Scarica dal browser',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final shortSize = tester.getSize(find.widgetWithText(CustomButton, 'No'));
    final longSize = tester.getSize(
      find.widgetWithText(CustomButton, 'Scarica dal browser'),
    );

    expect(longSize.width, greaterThan(shortSize.width * 2));
    await tester.tap(find.text('No'));
    expect(tappedShort, isTrue);
  });
}
