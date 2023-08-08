import 'package:flutter/material.dart';

class SnackBarMessage {
  final String message;
  final int durationInSec;
  final int? durationInMil;
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
          child: _buildSnackBarContent(context),
        ),
      );

  Widget _buildSnackBarContent(BuildContext context) => Padding(
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
