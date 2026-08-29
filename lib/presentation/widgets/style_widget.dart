
import 'package:flutter/material.dart';

class NumberedRule extends StatelessWidget {
  const NumberedRule({
    required this.number,
    required this.text,
    required this.style,
  });

  final String number;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number, style: style),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}