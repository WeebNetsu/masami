import 'package:flutter/material.dart';

void showError(
  BuildContext context,
  String text, {
  int duration = 3,
  bool error = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
      backgroundColor: error ? Colors.red : Colors.blue,
    ),
  );
}
