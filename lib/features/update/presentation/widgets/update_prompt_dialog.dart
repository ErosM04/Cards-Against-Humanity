import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/app_alert_dialog.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/release_section_box.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final accentColor = Theme.of(context).colorScheme.secondary;
    final sections = parseReleaseSections(release.description);

    return AppAlertDialog(
      image: Image.asset(
        'assets/dialog/update.png',
        scale: 9,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      title: 'Nuova versione disponibile!',
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
          Divider(height: 1, thickness: 2, color: accentColor),
          Flexible(
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                children: [
                  for (final entry in sections.entries)
                    ReleaseSectionBox(
                      title: entry.key,
                      items: entry.value,
                      accentColor: accentColor,
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Maggiori informazioni '),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(
                            release.releaseUrl.isNotEmpty
                                ? release.releaseUrl
                                : githubReleasesPageUrl,
                          ),
                        ),
                        child: const Text(
                          'qui',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 2, color: accentColor),
        ],
      ),
    );
  }

  /// Extracts `Funzionalità`, `Modifiche`, and `Bug fixes` bullet lists from GitHub markdown.
  static Map<String, List<String>> parseReleaseSections(String rawBody) {
    if (rawBody.trim().isEmpty) return const {};

    final cleaned =
        rawBody.replaceAll('\r', '').replaceAll('`', '').replaceAllMapped(
              RegExp(r'\[[^\]]*\]\(([^)]+)\)'),
              (m) => m.group(1) ?? '',
            );

    if (!cleaned.contains('###')) return const {};

    const trackedSections = ['Funzionalità', 'Modifiche', 'Bug fixes'];
    final sections = <String, List<String>>{};

    for (final part in cleaned.split('###')) {
      final lines = part.split('\n');
      final header = lines.first;
      for (final title in trackedSections) {
        if (!header.contains(title)) continue;
        final bulletLines = lines
            .skip(1)
            .map((line) => line.trim())
            .where((line) => line.startsWith('- '))
            .map((line) => line.substring(2).trim())
            .where((item) => item.isNotEmpty)
            .toList();
        final items = bulletLines.isNotEmpty
            ? bulletLines
            : part.contains('- ')
                ? part
                    .split('- ')
                    .sublist(1)
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList()
                : const <String>[];
        if (items.isNotEmpty) {
          sections[title] = items;
        }
        break;
      }
    }
    return sections;
  }
}
