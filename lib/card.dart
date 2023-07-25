import 'package:cards_against_humanity/logic/logic.dart';
import 'package:flutter/material.dart';

class CardAH extends StatefulWidget {
  final String text;
  final bool isClickable;
  final Function onClicked;
  final List<String> answersList;

  const CardAH({
    super.key,
    required this.text,
    this.isClickable = true,
    required this.onClicked,
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
          vertical: 10, horizontal: (widget.isClickable) ? 10 : 30),
      child: Container(
        width: (widget.isClickable) ? 200 : double.infinity,
        decoration: BoxDecoration(
          color: (isClicked)
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
              color: (widget.isClickable)
                  ? (isClicked)
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white
                  : Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: GestureDetector(
          onTap: () => (widget.isClickable) ? _isClicked() : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: (widget.isClickable) ? 30 : 40, horizontal: 20),
            child: buildCustomText(context),
          ),
        ),
      ),
    );
  }

  Widget buildCustomText(BuildContext context) => (widget.answersList.isEmpty)
      ? Text(
          widget.text,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: (widget.isClickable) ? 17 : 20,
              color: (widget.isClickable && isClicked)
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.white),
        )
      : RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
              style: const TextStyle(fontSize: 20, color: Colors.white),
              children: buildTextList()),
        );

  List<TextSpan> buildTextList() {
    List<TextSpan> textList = [];
    if (widget.text.contains('________')) {
      if (widget.answersList.length == 1) {
        if (widget.text.startsWith('________')) {
          // 1 answer and is at the start of the sentence
          textList = [
            buildCustomAnswerText(
                '${widget.answersList[0][0].toUpperCase()}${widget.answersList[0].substring(1)}'),
            TextSpan(text: widget.text.replaceAll('________', '')),
          ];
        } else {
          // 1 answer and is inside or at the end of the sentence
          List<String> tempList = widget.text.split('________');
          textList = [
            TextSpan(text: tempList[0]),
            buildCustomAnswerText(widget.answersList[0]),
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
            buildCustomAnswerText(
                '${widget.answersList[0][0].toUpperCase()}${widget.answersList[0].substring(1)}'),
            TextSpan(text: tempList[0]),
            buildCustomAnswerText(widget.answersList[1]),
            TextSpan(text: tempList[1]),
          ];
        } else {
          // 2 answer that are inside or at the end of the sentence
          var tempList = widget.text.split('________');
          tempList.removeWhere((element) => element == '');

          textList = [
            TextSpan(text: tempList[0]),
            buildCustomAnswerText(widget.answersList[0]),
            TextSpan(text: tempList[1]),
            buildCustomAnswerText(widget.answersList[1]),
            TextSpan(text: tempList[2]),
          ];
        }
      }
    } else {
      textList = [
        TextSpan(text: widget.text),
        buildCustomAnswerText(widget.answersList[0]),
      ];
    }
    return textList;
  }

  TextSpan buildCustomAnswerText(String text) => TextSpan(
      text: text.split(' - ')[1],
      style: TextStyle(color: Theme.of(context).colorScheme.secondary));

  void _isClicked() {
    if (isClicked) {
      // Removes the card from the selected card list
      CasualityManager.selectedCards.remove(widget.text);
      setState(() => isClicked = !isClicked);
    } else if (CasualityManager.selectedCards.length <
        CasualityManager.answerNeeded) {
      // Adds the card to the selected card list (if there is space for it)
      setState(() => isClicked = !isClicked);
      CasualityManager.selectedCards.add(widget.text);
      widget.onClicked();
    }
  }
}
