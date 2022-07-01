import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStep = 0;

  List<Step> _getSteps(ColorScheme theme) => [
        Step(
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 0,
          title: const Text("APK"),
          content: Center(
            child: MaterialButton(
              onPressed: () => {},
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Select MAS APK File",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Step(
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 1,
          title: const Text("Mods"),
          content: Center(
            child: MaterialButton(
              onPressed: () => {},
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Select Mods Folder",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Step(
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 2,
          title: const Text("Add"),
          content: Center(
            child: MaterialButton(
              onPressed: () => {},
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Add Mod",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Step(
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 3,
          title: const Text("Wait"),
          content: Center(
            child: MaterialButton(
              onPressed: () => {},
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Add Mod",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Step(
          isActive: _currentStep >= 4,
          title: const Text("Done"),
          content: Center(
            child: MaterialButton(
              onPressed: () => {},
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Add Mod",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stepper(
        // type: StepperType.horizontal,
        steps: _getSteps(theme),
        currentStep: _currentStep,
        onStepContinue: () => setState(() {
          _currentStep++;
        }),
        onStepCancel: () => setState(() {
          _currentStep--;
        }),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    // if the last step don't allow continue
                    onPressed: _currentStep != _getSteps(theme).length - 1
                        ? details.onStepContinue
                        : null,
                    color: theme.secondary,
                    textColor: Colors.white,
                    splashColor: Colors.red,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              // if (_currentStep != 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    // if the first step, don't allow cancel
                    onPressed: _currentStep < 1 ? null : details.onStepCancel,
                    color: theme.secondary,
                    textColor: Colors.white,
                    splashColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    disabledColor: Colors.grey,
                    child: const Text(
                      "Back",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
