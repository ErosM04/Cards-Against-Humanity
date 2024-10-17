import 'package:cards_against_humanity/core/gamelogic/logic.dart';
import 'package:flutter/material.dart';

/// Widget used to create the card widget, for answers, questions and both together.
/// To preserve state even when cards are out of the screen the State class comes with ``[AutomaticKeepAliveClientMixin]``.
class CardAH extends StatefulWidget {
  /// The text to display inside the card.
  final String text;

  /// Indicated if the card can be clicked to invoke certain actions and execute ``[onClicked]``.
  final bool isClickable;

  /// The function to call if [isClickable] is true and the card is clicked.
  final Function? onClicked;

  /// If this is true, this card has colored border to highlight its importance.
  final bool isMainCard;

  /// The list of answers to dislay in the empty spots of the question card.
  /// If empty only shows the text of the question.
  final List<String> answersList;

  const CardAH({
    super.key,
    required this.text,
    this.isClickable = true,
    this.onClicked,
    this.isMainCard = false,
    this.answersList = const [],
  });

  @override
  State<CardAH> createState() => _CardAHState();
}

class _CardAHState extends State<CardAH>
    with AutomaticKeepAliveClientMixin<CardAH> {
  bool isClicked = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 10, horizontal: (widget.isMainCard) ? 30 : 10),
      child: Container(
        width: (widget.isMainCard) ? double.infinity : 200,
        decoration: BoxDecoration(
          color: (widget.isClickable && isClicked)
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: (widget.isMainCard)
                ? (widget.isClickable)
                    ? (isClicked)
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary
                : (widget.isClickable)
                    ? (isClicked)
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white
                    : Colors.white,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: GestureDetector(
          onTap: () => (widget.isClickable) ? _isClicked() : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: (widget.isMainCard) ? 40 : 30, horizontal: 20),
            child: _buildCustomText(),
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
  Widget _buildCustomText() => SingleChildScrollView(
        child: (widget.answersList.isEmpty)
            ? Text(widget.text,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: (widget.isMainCard) ? 20 : 17,
                  color: (widget.isClickable && isClicked)
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
      text: text.split(' - ')[1],
      style: TextStyle(color: Theme.of(context).colorScheme.secondary));

  /// If it's activated (``[isClicked]`` is true) the aspect is changed, the card is added to the list in [CasualityManager]
  /// and the parameter method is called.
  void _isClicked() {
    if (isClicked) {
      // Removes the card from the selected card list
      CasualityManager.selectedCards.remove(widget.text);
      setState(() => isClicked = !isClicked);
    } else if (CasualityManager.selectedCards.length <
        CasualityManager.answersNeeded) {
      // Adds the card to the selected card list (if there is space for it)
      setState(() => isClicked = !isClicked);
      CasualityManager.selectedCards.add(widget.text);

      if (widget.onClicked != null) widget.onClicked!();
    }
  }
}
