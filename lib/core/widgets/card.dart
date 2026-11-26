import 'package:material_ui/material_ui.dart';

/// Widget used to create the card widget, for answers, questions and both together.
/// To preserve state even when cards are out of the screen the State class comes with ``[AutomaticKeepAliveClientMixin]``.
class CardAHW extends StatefulWidget {
  /// The text to display inside the card.
  final String text;

  /// Indicated if the card can be clicked to invoke certain actions and execute ``[onClicked]``.
  final bool isClickable;

  /// The function to call if [isClickable] is true and the card is clicked.
  final VoidCallback? onClicked;

  /// If this is true, this card has colored border to highlight its importance.
  final bool isMainCard;

  /// The list of answers to dislay in the empty spots of the question card.
  /// If empty only shows the text of the question.
  final List<String> answersList;

  /// If this card is currently selected.
  final bool isSelected;

  const CardAHW({
    super.key,
    required this.text,
    this.isClickable = true,
    this.onClicked,
    this.isMainCard = false,
    this.answersList = const [],
    this.isSelected = false,
  });

  @override
  State<CardAHW> createState() => _CardAHWState();
}

class _CardAHWState extends State<CardAHW>
    with AutomaticKeepAliveClientMixin<CardAHW> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isCardActive = widget.isClickable && widget.isSelected;
    final borderColor = isCardActive
        ? colorScheme.secondary
        : widget.isMainCard
            ? colorScheme.primary
            : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 14, horizontal: (widget.isMainCard) ? 30 : 12),
      child: Container(
        width: (widget.isMainCard) ? double.infinity : 200,
        decoration: BoxDecoration(
          color: isCardActive ? colorScheme.primary : const Color(0xFF232327),
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: borderColor.withAlpha(95),
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
        child: GestureDetector(
          onTap: () => widget.isClickable ? widget.onClicked?.call() : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: (widget.isMainCard) ? 40 : 30, horizontal: 20),
            child: _buildCustomText(isCardActive),
          ),
        ),
      ),
    );
  }

  /// If a list of answers is passed as a parameter (so it isn't empty) returns a ``[RichText]`` containg the question
  /// with the answers.
  /// Otherwise returns a ``[Text]`` using the text parameter.
  ///
  /// Both cases the widget is enclosed in a ``[SingleChildScrollView]`` to scroll the text if it's too long.
  Widget _buildCustomText(bool isCardActive) => SingleChildScrollView(
        child: (widget.answersList.isEmpty)
            ? Text(widget.text,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: (widget.isMainCard) ? 20 : 17,
                  color: isCardActive
                      ? Theme.of(context).colorScheme.tertiary
                      : Colors.white,
                ))
            : RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    children: _buildTextList()),
              ),
      );

  /// Builds a list of ``[TextSpan]`` where the question (text parameter) is white and the answers (taken by the list
  /// of answers) use a color of the theme and are substituted to the '_____' contained in the question string.
  List<TextSpan> _buildTextList() {
    List<TextSpan> textList = [];
    if (widget.text.contains('________')) {
      if (widget.answersList.length == 1) {
        if (widget.text.startsWith('________')) {
          // 1 answer and is at the start of the sentence
          textList = [
            _buildCustomAnswerText(
                '${widget.answersList[0][0].toUpperCase()}${widget.answersList[0].substring(1)}'),
            TextSpan(text: widget.text.replaceAll('________', '')),
          ];
        } else {
          // 1 answer and is inside or at the end of the sentence
          List<String> tempList = widget.text.split('________');
          textList = [
            TextSpan(text: tempList[0]),
            _buildCustomAnswerText(widget.answersList[0]),
            (tempList.length > 1)
                ? TextSpan(text: tempList[1])
                : const TextSpan(),
          ];
        }
      } else {
        if (widget.text.startsWith('________')) {
          // 2 answer and the first is at the start of the sentence
          var tempList = widget.text.split('________');
          tempList.removeWhere((element) => element == '');

          textList = [
            _buildCustomAnswerText(
                '${widget.answersList[0][0].toUpperCase()}${widget.answersList[0].substring(1)}'),
            TextSpan(text: tempList[0]),
            _buildCustomAnswerText(widget.answersList[1]),
            TextSpan(text: tempList[1]),
          ];
        } else {
          // 2 answer that are inside or at the end of the sentence
          var tempList = widget.text.split('________');
          tempList.removeWhere((element) => element == '');

          textList = [
            TextSpan(text: tempList[0]),
            _buildCustomAnswerText(widget.answersList[0]),
            TextSpan(text: tempList[1]),
            _buildCustomAnswerText(widget.answersList[1]),
            TextSpan(text: tempList[2]),
          ];
        }
      }
    } else {
      textList = [
        TextSpan(text: widget.text),
        _buildCustomAnswerText(widget.answersList[0]),
      ];
    }
    return textList;
  }

  /// Builds a custom ``[TextSpan]`` which uses the color of the scheme (used for answers).
  TextSpan _buildCustomAnswerText(String text) => TextSpan(
      text: text.contains(' - ') ? text.split(' - ')[1] : text,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary));
}
