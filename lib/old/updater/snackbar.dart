import 'package:flutter/material.dart';

/// Pre-fabricated ``[SnackBar]``.
class SnackBarMessage {
  /// The text message to display in the center of the SnackBar.
  final String message;

  /// The duration in seconds.
  final int durationInSec;

  /// The duration in milliseconds, if a values is assegned, this duration is used in place of ``[durationInSec]``.
  final int? durationInMil;

  /// The font size of the ``[message]``.
  final double fontSize;

  const SnackBarMessage({
    required this.message,
    this.durationInSec = 3,
    this.durationInMil,
    this.fontSize = 15,
  });

  SnackBar build(BuildContext context) => SnackBar(
        elevation: 0, // removes shadow
        behavior: SnackBarBehavior.floating,
        width: double.infinity,
        duration: (durationInMil == null)
            ? Duration(seconds: durationInSec)
            : Duration(milliseconds: durationInMil!),
        backgroundColor: Colors.transparent,
        content: Container(
          height: (message.length <= 40) ? 45 : 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black,
          ),
          child: _buildSnackBarContent(),
        ),
      );

  /// Builds the text contained in the [SnackBar].
  Widget _buildSnackBarContent() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 3),
          ],
        ),
      );
}
