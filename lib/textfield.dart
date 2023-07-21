import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.number,
          // decoration: InputDecoration(
          //     enabledBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.white),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.grey.shade400),
          //     ),
          //     fillColor: Colors.grey.shade200,
          //     filled: true,
          //     hintStyle: TextStyle(color: Colors.grey[500])),
        ),
      );
}
