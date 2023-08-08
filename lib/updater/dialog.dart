import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Used to create the content for the update dialog
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
    // Reads the changes and extracts different types of data:
    // - Funzionalità
    // - Cambiamenti
    // - Bug fixes
    // Each element has it's own list of information. Apart from these, it also creates a title and a link to the release.

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

  /// Takes a list of strings where each string is a description of a change and returns the complete list version.
  /// If the single row is too long (over 54), is clamped at the end and '...' are added.
  /// E.g.:
  /// ```
  /// rows = ['### Funzionalità', 'Aggiunto un bottone', 'Ora puoi ascoltare gli audio, bla bla bla bla']
  /// ```
  /// Result:
  /// ```
  /// """
  /// - Aggiunto un bottone
  /// - Ora puoi ascoltare gli audio, bla bla...
  /// """
  /// ```
  ///
  /// #### Parameters
  /// - ``List<String> [rows]`` : the list of rows where each rows is a element of the list. Apart from the first element which is the title.
  ///
  /// #### Returns
  /// ``String`` : The complete text with every row starting with a '-'.
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

  /// Graphically build the content using a Column and adding all the elemnts that are not null.
  /// To check if an element is null and not empty ``[_safeBuild]`` method is used.
  /// #### Parameters
  /// - ``String [mainText]`` : the text on the top ``'Vuoi scaricale la versione vx.x.x'``
  /// - ``String? [subTitle1]`` : the first subtitle
  /// - ``String? [subTitle2]`` : the second subtitle
  /// - ``String? [subTitle3]`` : the third subtitle
  /// - ``String? [text1]`` : the first text (under the 1st subtitle)
  /// - ``String? [text2]`` : the second text (under the 2nd subtitle)
  /// - ``String? [text3]`` : the third text (under the 3th subtitle)
  /// - ``String? [linkText]`` : the text befor the link
  /// - ``String? [link]`` : the link text
  ///
  /// #### Returns
  /// ``[Column]`` : the column with all the children.
  Widget buildDialog(
      {required String mainText,
      String? subTitle1,
      String? subTitle2,
      String? subTitle3,
      String? text1,
      String? text2,
      String? text3,
      String? linkText,
      String? link}) {
    Column column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );

    // Version title
    column.children.add(_buildText(mainText));
    column.children.add(const SizedBox(height: 20));

    // Functionalities
    column.children
        .add(_safeBuild(subTitle1, _buildText(subTitle1, isBold: true)));
    column.children.add(_safeBuild(subTitle1, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text1, _buildText(text1)));
    column.children.add(_safeBuild(text1, const SizedBox(height: 8)));

    // Changes
    column.children
        .add(_safeBuild(subTitle2, _buildText(subTitle2, isBold: true)));
    column.children.add(_safeBuild(subTitle2, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text2, _buildText(text2)));
    column.children.add(_safeBuild(text2, const SizedBox(height: 8)));

    // Bug fixies
    column.children
        .add(_safeBuild(subTitle3, _buildText(subTitle3, isBold: true)));
    column.children.add(_safeBuild(subTitle3, const SizedBox(height: 4)));
    column.children.add(_safeBuild(text3, _buildText(text3)));
    column.children.add(_safeBuild(text3, const SizedBox(height: 8)));
    column.children.add(const SizedBox(height: 15));

    // Link
    column.children.add(_safeBuild(linkText, _buildText(linkText)));
    column.children.add(_safeBuild(link, _buildLink(link)));

    return column;
  }

  /// Allows to securely build [widget] only if the [str] is not null and not empty.
  Widget _safeBuild(String? str, Widget widget) =>
      (str != null && str.isNotEmpty) ? widget : Container();

  /// Returns a [Text] widget. If ``[text]`` is null, then is converted to an empty String ('').
  /// If ``[isLink]`` is true, then the text is blue and underlined. If ``[isBold]`` is true then the text is bold.
  /// ``[isBold]`` doesn't affect the link version of the text.
  Text _buildText(String? text, {bool isLink = false, bool isBold = false}) =>
      (isLink)
          ? Text((text == null) ? '' : text.trim(),
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ))
          : Text(
              (text == null) ? '' : text.trim(),
              style: TextStyle(fontWeight: (isBold) ? FontWeight.bold : null),
            );

  /// Returns the clickable link to the latest GitHub release. To build the text uses ``[_buildText]``.
  Widget _buildLink(String? text) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(
            'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest')),
        child: _buildText(text, isLink: true),
      );
}
