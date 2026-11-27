import 'package:material_ui/material_ui.dart';

/// Displays a centered floating rounded SnackBar sized to [message], font size, and screen dimensions.
void showCustomSnackBar(
  BuildContext context,
  String message, {
  int durationSeconds = 2,
}) {
  final screenSize = MediaQuery.sizeOf(context);
  final minWidth = (screenSize.width * 0.35).clamp(110.0, 260.0);
  final minHeight = (screenSize.height * 0.055).clamp(40.0, 64.0);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: durationSeconds),
      backgroundColor: Colors.transparent,
      content: Center(
        heightFactor: 1,
        child: Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
}
