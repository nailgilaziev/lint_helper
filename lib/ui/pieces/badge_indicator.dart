import 'package:flutter/material.dart';

class BadgeIndicator extends StatelessWidget {
  const BadgeIndicator(
    this.text, {
    Key? key,
    required this.active,
    required this.activeColor,
  }) : super(key: key);

  final String text;
  final bool active;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    const wh = 16.0;
    return Container(
        width: wh,
        height: wh,
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text[0],
            textScaleFactor: 0.7,
            textAlign: TextAlign.center,
          ),
        ));
  }
}
