import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/app_alert_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog displayed when APK installation fails, offering retry or browser download.
class InstallErrorDialog extends StatelessWidget {
  final String errorType;
  final VoidCallback onRetry;
  final VoidCallback onBrowserDownload;
  final VoidCallback onDeny;

  const InstallErrorDialog({
    super.key,
    required this.errorType,
    required this.onRetry,
    required this.onBrowserDownload,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return AppAlertDialog(
      image: Image.asset(
        'assets/dialog/error.png',
        scale: 9,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      title: "Errore durante l'installazione dell'aggiornamento",
      actions: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _dialogButton(context, 'Riprova', onRetry),
          _dialogButton(context, 'Scarica dal browser', onBrowserDownload),
          _dialogButton(context, 'Annulla', onDeny),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vuoi riprovare l'installazione o scaricare l'aggiornamento dal browser?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Divider(color: accentColor),
            const SizedBox(height: 5),
            const Text(
              "Durante l'installazione dell'aggiornamento si è verificato un errore:",
            ),
            const SizedBox(height: 3),
            if (errorType.isNotEmpty)
              Text(errorType.trim(), style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 5),
            Divider(color: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton(
    BuildContext context,
    String text,
    VoidCallback action,
  ) =>
      CustomButton(
        text: text,
        fontSize: 16,
        horizontalInternalPadding: 18,
        onPressed: () {
          Navigator.pop(context);
          action();
        },
      );
}
