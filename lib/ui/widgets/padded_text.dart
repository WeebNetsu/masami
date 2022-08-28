import 'package:flutter/material.dart';

class PaddedText extends StatelessWidget {
  const PaddedText(
    this.text, {
    Key? key,
    this.padding,
    this.style,
  }) : super(key: key);

  final String text;
  final double? padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding ?? 10),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
