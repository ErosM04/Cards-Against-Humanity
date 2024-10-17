import 'package:flutter/material.dart';

/// Pre-fabricated ``[TextField]`` with phone keyboard.
class CustomTextField extends StatelessWidget {
  /// The controller of the ``[TextField]``.
  final TextEditingController controller;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        // Used to priviledge numbers over letters and still access the '.' character.
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return "Non hai scritto un cazzo";
          }
          return null;
        },
      );
}
