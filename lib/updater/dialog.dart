import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogContent extends StatelessWidget {
  final String latestVersion;
  final String? changes;

  const DialogContent({
    super.key,
    required this.latestVersion,
    this.changes,
  });

  @override
  Widget build(BuildContext context) {
    String? title1;
    String? title2;
    String? title3;
    String text1 = '';
    String text2 = '';
    String text3 = '';
    String? link;
    String? linkText;

    if (changes != null && changes!.isNotEmpty) {
      String tempChanges = changes!
          .replaceAll('\r', '')
          .replaceAll('\n', '')
          .replaceAll('``', '');

      if (tempChanges.contains('###') &&
          (tempChanges.contains('Funzionalità') ||
              tempChanges.contains('Cambiamenti') ||
              tempChanges.contains('Bug fixes'))) {
        List<String> arr = tempChanges.split('###');
        title1 = '';
        title2 = '';
        title3 = '';

        for (var element in arr) {
          if (element.contains('Funzionalità') && element.contains('-')) {
            title1 = 'Funzionalità';
            text1 = _composeRows(element.split('-'));
          } else if (element.contains('Cambiamenti')) {
            title2 = 'Cambiamenti';
            text2 = _composeRows(element.split('-'));
          } else if (element.contains('Bug fixes')) {
            title3 = 'Bug fixes';
            text3 += '- Alcuni bug fixes';
          }
        }
        linkText = 'Più informazioni a:';
        link = 'Cards-Against-Humanity';
      }
    }

    return buildDialog(
      mainText: 'Scaricare versione $latestVersion?',
      subTitle1: title1,
      subTitle2: title2,
      subTitle3: title3,
      text1: text1,
      text2: text2,
      text3: text3,
      linkText: linkText,
      link: link,
    );
  }

  String _composeRows(List<String> rows) {
    String str = '';

    for (var i = 1; i < rows.length; i++) {
      if (rows[i].trim().length <= 55) {
        str += '- ${rows[i].trim()}\n';
      } else {
        str += '- ${rows[i].trim().substring(0, 55)}...\n';
      }
    }
    return str;
  }

  Widget buildDialog(
          {required String mainText,
          String? subTitle1,
          String? subTitle2,
          String? subTitle3,
          String? text1,
          String? text2,
          String? text3,
          String? linkText,
          String? link}) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version title
          _buildText(mainText),
          const SizedBox(height: 20),
          // Functionalities
          (subTitle1 != null && subTitle1.isNotEmpty)
              ? _buildText(subTitle1, isBold: true)
              : Container(),
          (subTitle1 != null && subTitle1.isNotEmpty)
              ? const SizedBox(height: 4)
              : Container(),
          (text1 != null && text1.isNotEmpty) ? _buildText(text1) : Container(),
          (text1 != null && text1.isNotEmpty)
              ? const SizedBox(height: 8)
              : Container(),
          // Changes
          (subTitle2 != null && subTitle2.isNotEmpty)
              ? _buildText(subTitle2, isBold: true)
              : Container(),
          (subTitle2 != null && subTitle2.isNotEmpty)
              ? const SizedBox(height: 4)
              : Container(),
          (text2 != null && text2.isNotEmpty) ? _buildText(text2) : Container(),
          (text2 != null && text2.isNotEmpty)
              ? const SizedBox(height: 8)
              : Container(),
          // Bug fixies
          (subTitle3 != null && subTitle3.isNotEmpty)
              ? _buildText(subTitle3, isBold: true)
              : Container(),
          (subTitle3 != null && subTitle3.isNotEmpty)
              ? const SizedBox(height: 4)
              : Container(),
          (text3 != null && text3.isNotEmpty) ? _buildText(text3) : Container(),
          const SizedBox(height: 20),
          // Link
          (linkText != null &&
                  linkText.isNotEmpty &&
                  link != null &&
                  link.isNotEmpty)
              ? _buildText(linkText)
              : Container(),
          (link != null && link.isNotEmpty) ? _buildLink(link) : Container(),
        ],
      );

  Text _buildText(String text, {bool isLink = false, bool isBold = false}) =>
      (isLink)
          ? Text(text.trim(),
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ))
          : Text(
              text.trim(),
              style: TextStyle(fontWeight: (isBold) ? FontWeight.bold : null),
            );

  Widget _buildLink(String text) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(
            'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest')),
        child: _buildText(text, isLink: true),
      );
}
