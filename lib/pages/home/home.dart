import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentStep = 0;
  PlatformFile? _selectedAPK = null;
  List<PlatformFile> _selectedMods = [];

  void _selectAPK() async {
    // below video contains a lot of useful tips!! Such as
    // https://youtu.be/LlO5jydXws0
    // if you want to allow multiple files to be chosen, then
    // pickFiles(allowMultiple: true)
    final result = await FilePicker.platform.pickFiles(
      // below are optional to add, but it makes it easy to only
      // allow selecting specific types of files
      type: FileType.custom,
      allowedExtensions: ["apk"],
    );

    // if no file was chosen
    if (result == null) return;

    setState(() {
      // result.files.first = only choose the first selected file
      _selectedAPK = result.files.first;
    });

    // easily get file info
    // print("Name: ${file.name}");
    // on flutter web you'd get bytes returned
    // print("Bytes: ${file.bytes}");
    // print("Size: ${file.size}");
    // print("Extension: ${file.extension}");
    // file will be stored in cache directory
    // by default, if app is deleted or restarted then
    // cache file is too
    // print("Path: ${file.path}");
  }

  void _selectMods() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );

    if (result == null) return;

    setState(() {
      _selectedMods = result.files;
    });
  }

  Future<File> _saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File("${appStorage.path}/${file.name}");

    return File(file.path!).copy(newFile.path);
  }

  // NOTE: when releasing the app, make sure to follow the below setup!!!!
  // ! https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android
  List<Step> _getSteps(ColorScheme theme) => [
        Step(
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 0,
          title: const Text("Select APK"),
          content: Center(
            child: MaterialButton(
              // when using async, => is not required
              onPressed: _selectAPK,
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
          title: const Text("Select Mods"),
          content: Center(
            child: MaterialButton(
              onPressed: _selectMods,
              color: theme.secondary,
              textColor: Colors.white,
              splashColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: const Text(
                "Select Mod Files",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Step(
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 2,
          title: const Text("Review Changes"),
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
                "Wait",
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

  // below is syntax for a function that returns a void function
  void Function()? _getNextStep(ControlsDetails details, ColorScheme theme) {
    if (_currentStep == _getSteps(theme).length - 1) return null;

    switch (_currentStep) {
      case 0: // if selecting APK
        if (_selectedAPK != null) return details.onStepContinue;
        break;
      case 1: // if selecting mods
        if (_selectedMods.isNotEmpty) return details.onStepContinue;
        break;
      default:
        return null;
    }

    return null;
  }

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
                    onPressed: _getNextStep(details, theme),
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
