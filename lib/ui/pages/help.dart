import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key, required this.title});

  final String title;

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Text("The Help Page"),
        ],
      ),
    );
  }
}
