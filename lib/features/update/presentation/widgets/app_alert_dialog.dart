import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';

/// Shared animated confirmation dialog used across update prompts and error fallbacks.
class AppAlertDialog extends StatelessWidget {
  final Image image;
  final String title;
  final Widget child;
  final String denyButtonText;
  final String confirmButtonText;
  final VoidCallback? onDeny;
  final VoidCallback? onConfirm;
  final Widget? actions;
  final bool isError;

  const AppAlertDialog({
    super.key,
    required this.image,
    required this.title,
    required this.child,
    this.denyButtonText = 'No',
    this.confirmButtonText = 'Sì',
    this.onDeny,
    this.onConfirm,
    this.actions,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final headerColor =
        (isError) ? Colors.red : Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxDialogWidth = screenWidth >= 600
        ? (screenWidth * 0.5).clamp(300.0, 560.0)
        : double.infinity;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image
                        .animate()
                        .rotate(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.linearToEaseOut,
                        )
                        .rotate(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.linearToEaseOut,
                          begin: 1,
                          end: 0,
                        ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(child: child),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: actions ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(context, denyButtonText, onDeny ?? () {}),
                      _actionButton(
                        context,
                        confirmButtonText,
                        onConfirm ?? () {},
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String text,
    VoidCallback action,
  ) =>
      CustomButton(
        text: text,
        fontSize: 16,
        horizontalInternalPadding: 18,
        onPressed: () {
          action();
          Navigator.pop(context);
        },
      );
}
