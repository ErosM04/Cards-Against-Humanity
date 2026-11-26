import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
  });

  @override
  Widget build(BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
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
      );

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

/// Dialog prompting the user to download a newly available GitHub release.
class UpdatePromptDialog extends StatelessWidget {
  final AppRelease release;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;

  const UpdatePromptDialog({
    super.key,
    required this.release,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final sections = parseReleaseSections(release.description);

    return AppAlertDialog(
      image: Image.asset(
        'assets/dialog/update.png',
        scale: 9,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      title: 'Nuova versione disponibile',
      onDeny: onDeny,
      onConfirm: onConfirm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scaricare la versione ${release.version}?',
            style: const TextStyle(fontSize: 16.5),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 2),
          const SizedBox(height: 10),
          for (final entry in sections.entries) ...[
            Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            for (final item in entry.value.take(3)) _bulletRow(item),
            if (entry.value.length > 3) _bulletRow('. . .'),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Più informazioni:'),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(
                    release.releaseUrl.isNotEmpty
                        ? release.releaseUrl
                        : githubReleasesPageUrl,
                  ),
                ),
                child: const Text(
                  'Cards Against Humanity',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 2),
        ],
      ),
    );
  }

  Widget _bulletRow(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('-'),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              text.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  /// Extracts `Funzionalità`, `Modifiche`, and `Bug fixes` bullet lists from GitHub markdown.
  static Map<String, List<String>> parseReleaseSections(String rawBody) {
    if (rawBody.trim().isEmpty) return const {};

    final cleaned = rawBody
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll('``', '')
        .replaceAllMapped(
          RegExp(r'\[[^\]]*\]\(([^)]+)\)'),
          (m) => m.group(1) ?? '',
        );

    if (!cleaned.contains('###')) return const {};

    final sections = <String, List<String>>{};
    for (final part in cleaned.split('###')) {
      if (part.contains('Funzionalità') && part.contains('- ')) {
        sections['Funzionalità'] = part.split('- ').sublist(1);
      } else if (part.contains('Modifiche') && part.contains('- ')) {
        sections['Modifiche'] = part.split('- ').sublist(1);
      } else if (part.contains('Bug fixes')) {
        sections['Bug fixes'] = const ['Alcuni bug fixes'];
      }
    }
    return sections;
  }
}

/// Dialog showing live APK download progress driven by [UpdateBloc].
class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Download in corso',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                BlocBuilder<UpdateBloc, UpdateState>(
                  builder: (context, state) {
                    final progress = state is UpdateDownloadInProgress
                        ? state.progress.clamp(0.0, 1.0)
                        : 1.0;
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        SizedBox(
                          height: 55,
                          width: 55,
                          child: CircularProgressIndicator(
                            value: progress,
                            color: Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            strokeWidth: 6.5,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
}

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
  Widget build(BuildContext context) => AppAlertDialog(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vuoi riprovare l'installazione o scaricare l'aggiornamento dal browser?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 5),
            const Text(
              "Durante l'installazione dell'aggiornamento si è verificato un errore:",
            ),
            const SizedBox(height: 3),
            if (errorType.isNotEmpty)
              Text(errorType.trim(), style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 5),
            const Divider(),
          ],
        ),
      );

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
