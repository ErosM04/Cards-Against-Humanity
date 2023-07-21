import 'package:flutter/material.dart';

class CardAH extends StatefulWidget {
  final String text;
  final bool isClickable;
  final Function onClicked;

  const CardAH({
    super.key,
    required this.text,
    this.isClickable = true,
    required this.onClicked,
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
            child: Text(
              widget.text,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: (widget.isClickable) ? 17 : 20,
                  color: (widget.isClickable && isClicked)
                      ? Theme.of(context).colorScheme.tertiary
                      : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _isClicked() {
    setState(() => isClicked = !isClicked);
    widget.onClicked();
  }
}
