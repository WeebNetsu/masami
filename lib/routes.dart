import 'package:flutter/material.dart';
import 'package:masami/ui/pages/help.dart';
import 'package:masami/ui/pages/home.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const HomePage(title: 'MASAMI'),
  "/help": (context) => const HelpPage(title: 'MOD Install Help'),
};
