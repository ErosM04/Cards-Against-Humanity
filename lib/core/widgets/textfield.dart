import 'package:material_ui/material_ui.dart';

/// Pre-fabricated detached white-bordered input box with phone keyboard and validation.
class CustomTextField extends StatelessWidget {
  /// The controller of the input field.
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
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FormField<String>(
        initialValue: controller.text,
        validator: (_) {
          final text = controller.text;
          if (text.trim().isEmpty) {
            return "Non hai scritto un cazzo!";
          }
          return validator?.call(text);
        },
        builder: (field) {
          final effectiveError = errorText ?? field.errorText;
          final hasError = effectiveError != null && effectiveError.isNotEmpty;
          final idleBorderColor =
              hasError ? errorColor : Colors.white.withAlpha(220);
          final activeBorderColor = hasError ? errorColor : Colors.white;
          final glowColor = hasError ? errorColor : Colors.white;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withAlpha(95),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(200),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  // Used to priviledge numbers over letters and still access the '.' character.
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    field.didChange(value);
                    onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF232327),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: idleBorderColor,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: activeBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 14, right: 8),
                  child: Text(
                    effectiveError,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: errorColor, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
