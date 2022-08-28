import 'package:flutter/material.dart';
import 'package:masami/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASAMI',
      theme: Theme.of(context).copyWith(
        // https://docs.flutter.dev/cookbook/design/themes#extending-the-parent-theme
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFEB98BA),
              secondary: const Color(0xFFEB85AD),
            ),
      ),
      routes: routes,
    );
  }
}
