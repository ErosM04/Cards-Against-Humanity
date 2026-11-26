import 'package:material_ui/material_ui.dart';

/// Pre-fabricated [TextFormField] with phone keyboard and customizable validation.
class CustomTextField extends StatelessWidget {
  /// The controller of the [TextFormField].
  final TextEditingController controller;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  /// Optional validator run after checking for non-empty input.
  final String? Function(String? value)? validator;

  /// Optional external error text (e.g., from async BLoC validation failures).
  final String? errorText;

  /// Called whenever the field value changes.
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        // Used to priviledge numbers over letters and still access the '.' character.
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          errorText: errorText,
          errorMaxLines: 3,
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Non hai scritto un cazzo!";
          }
          return validator?.call(value);
        },
      );
}
