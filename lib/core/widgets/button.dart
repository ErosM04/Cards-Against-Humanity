import 'package:material_ui/material_ui.dart';

/// Custom button with app style.
class CustomButton extends StatelessWidget {
  /// The text to display inside the button.
  final String text;

  /// The function to call after the button is pressed.
  final VoidCallback onPressed;

  /// The color of the button, if no value is provided the color chosen is the first of the theme.
  final Color? color;

  /// The color of the [text], default is black.
  final Color? textColor;

  /// The internal vertical padding of the text.
  final double verticalInternalPadding;

  /// The internal horizontal padding of the text.
  final double horizontalInternalPadding;

  /// The size of [text].
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor = Colors.black,
    this.verticalInternalPadding = 10,
    this.horizontalInternalPadding = 15,
    this.fontSize = 25,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(color)),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalInternalPadding,
            horizontal: horizontalInternalPadding,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
}
