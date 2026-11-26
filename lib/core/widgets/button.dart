import 'package:material_ui/material_ui.dart';

/// Custom elevated button whose horizontal width adapts to its [text] length.
class CustomButton extends StatelessWidget {
  /// The text to display inside the button.
  final String text;

  /// The function to call after the button is pressed.
  final VoidCallback onPressed;

  /// The color of the button, if no value is provided the color chosen is the first of the theme.
  final Color? color;

  /// The color of the [text], default is black.
  final Color? textColor;

  /// The internal vertical padding around [text].
  final double verticalInternalPadding;

  /// The internal horizontal padding around [text].
  final double horizontalInternalPadding;

  /// The size of [text].
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor = Colors.black,
    this.verticalInternalPadding = 12,
    this.horizontalInternalPadding = 24,
    this.fontSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withAlpha(90),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(effectiveColor),
          shadowColor: WidgetStatePropertyAll(effectiveColor.withAlpha(160)),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? 1 : 6,
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              vertical: verticalInternalPadding,
              horizontal: horizontalInternalPadding,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withAlpha(75),
                width: 1.5,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
