import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:masami/models/progress.dart';
import 'package:masami/utils/file_management.dart';
import 'package:masami/utils/globals.dart';
import 'package:masami/utils/views.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The current step our stepper is on, starts at 0, not 1
  int _currentStep = 3;
  PlatformFile? _selectedAPK;
  List<PlatformFile> _selectedMods = [];
  Progress? _modApplyProgress;
  final Uri _telegramBotUrl = Uri.parse('https://t.me/Copyrighted_bot');
  final Uri _masDiscordChatUrl = Uri.parse('https://discord.gg/XjfgvnCvYM');
  bool _loadingData = false;
  String? _pathToApk;
  List<PlatformFile> _selectedCustomGifts = [];

  // since context doesn't like to be used in async
  void displayError(String text) => showError(context, text);

  /// Will open the file picker to select an APK.\
  void _selectAPK() async {
    setState(() {
      _loadingData = true;
    });
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

    setState(() {
      // result.files.first = only choose the first selected file
      // if file was chosen
      if (result != null) _selectedAPK = result.files.first;

      _loadingData = false;
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

  /// Select gifts to add to game
  void _selectCustomGifts() async {
    // todo still incomplete
    setState(() {
      _loadingData = true;
    });

    final appDir = await getAppDir();

    if (appDir == null) {
      displayError("Could not get app folder.");

      setState(() {
        _loadingData = false;
      });

      return;
    }

    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: true);

    setState(() {
      // result.files.first = only choose the first selected file
      // if file was chosen
      if (result != null) _selectedCustomGifts.addAll(result.files);

      _loadingData = false;
    });
  }

  void _applyCustomGifts() async {
    // todo still incomplete
    // what we could do is we could copy the com.ddlc.mas folder to our app dir
    // then we can just tell the user to move the file to Android/data to apply the changes
    setState(() {
      _loadingData = true;
    });

    final appDir = await getAppDir();

    if (appDir == null) {
      displayError("Could not get app folder.");

      setState(() {
        _loadingData = false;
      });

      return;
    }

    var f = File("${appDir.parent.parent}/com.ddlc.mas/added.txt");
    print(f);
    setState(() {
      // result.files.first = only choose the first selected file
      // if file was chosen
      // if (result != null) _selectedCustomGifts.addAll(result.files);

      _loadingData = false;
    });
  }

  /// Will open the file picker to select the MODS. All mods has to be of type .zip
  void _selectMods() async {
    setState(() {
      _loadingData = true;
    });

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );

    if (result == null) return;

    setState(() {
      _selectedMods = result.files;
      _loadingData = false;
    });
  }

  /// Integrate mods with APK, will take multiple mods and add them to MAS APK
  Future<void> _addMod() async {
    setState(() {
      _loadingData = true;
      _modApplyProgress = Progress(6, "Cleaing data directory");
    });

    // step 1
    // clean data dir before trying to add files and folders to it again
    var cleanedDataDir = await cleanDataDir();
    if (!cleanedDataDir) {
      displayError("Could not clean data folder");

      setState(() {
        _loadingData = false;
      });

      return;
    }

    setState(() {
      _modApplyProgress?.increaseProgress("Extracting mods");
    });

    // step 2
    // we extract mods first, since there will be more and a higher change of error
    if (_selectedMods.isEmpty) {
      displayError("No mods were provided");

      setState(() {
        _loadingData = false;
      });

      return;
    }

    // this directory is the one that contains all the extracted mod folders in it
    Directory? extractedModsDir;
    for (var file in _selectedMods) {
      // extract mod from .zip file and save in mod folder
      Directory? extractedMod = await extractZip(file, "mod/${file.name}");

      if (extractedMod == null) return;
      // print("${file.name} extracted");

      extractedModsDir ??= extractedMod;
    }

    if (extractedModsDir == null) return;

    setState(() {
      _modApplyProgress?.increaseProgress("Extracting APK");
    });

    // step 3
    if (_selectedAPK == null) return;

    // extract MAS APK
    // ! Unhandled Exception: FormatException: Invalid Zip Signature?
    Directory? extractedApkDir = await extractZip(_selectedAPK!, "apk/mas.zip");

    if (extractedApkDir == null) {
      displayError("Could not find extracted apk folder");

      setState(() {
        _loadingData = false;
      });

      return;
    }

    setState(() {
      _modApplyProgress?.increaseProgress("Renaming mods");
    });

    // step 4
    List<Directory> modDirs = [];

    // add mod FOLDERS to modDirs list, since we'll be messing with them mainly
    for (FileSystemEntity mod in extractedModsDir.listSync()) {
      if (mod is Directory) modDirs.add(mod);
    }

    for (Directory mod in modDirs) {
      // rename all files and folders in current mod folder
      for (FileSystemEntity dir in mod.listSync()) {
        bool renameSuccess = await recursiveRename(dir);

        if (!renameSuccess) return;
      }
    }

    setState(() {
      _modApplyProgress?.increaseProgress("Copying mods to APK");
    });

    // step 5
    // apply mods by copying files to APK dir
    bool applyModSuccess = await applyModFiles();

    if (!applyModSuccess) return;

    setState(() {
      _modApplyProgress?.increaseProgress("Zipping MAS APK");
    });

    // step 6
    // Generate a .zip file from apk directory
    File? masZipped = await createMASZip();
    if (masZipped == null) return;
    bool wasZipped = await masZipped.exists();
    if (!wasZipped) return;

    // rename .zip file to .apk
    // ! the below does not produce a valid APK!
    renameFile("mas.apk", masZipped);

    Directory? appDir = await getAppDir();

    setState(() {
      _pathToApk = appDir?.path;
      _modApplyProgress?.increaseProgress("Done!");
      _loadingData = false;
    });

    // we need to move gifts stuff to the MAS directory
    // this is an optional feature we can add
    // https://youtu.be/3SnwZwhXnNE?t=695
  }

  /// Get next step in progress
  void Function()? _getNextStep(ControlsDetails details, ColorScheme theme) {
    if (_currentStep == _getSteps(theme).length - 1) return null;

    switch (_currentStep) {
      case 0: // if selecting APK
        if (_selectedAPK != null) return details.onStepContinue;
        break;
      case 1: // if selecting mods
        if (_selectedMods.isNotEmpty) return details.onStepContinue;
        break;
      case 2: // if adding mods
        if (_modApplyProgress == null) return null;

        if (_selectedMods.isNotEmpty &&
            _modApplyProgress!.getProgressComplete()) {
          return details.onStepContinue;
        }
        break;
      case 3: // if applying gifts
        return details.onStepContinue;
      default:
        return null;
    }

    return null;
  }

  /// Get current progress from _modApplyProgress
  double _getProgressValue() {
    if (_modApplyProgress == null) return 0;

    double progress = _modApplyProgress!.getProgress();
    if (progress == 0) return 0;

    progress = _modApplyProgress!.getProgress() / 100;

    return double.parse(progress.toStringAsFixed(2));
  }

  // NOTE: when releasing the app, make sure to follow the below setup!!!!
  // ! https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android
  List<Step> _getSteps(ColorScheme theme) => [
        Step(
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 0,
          title: const Text("Select APK"),
          content: Center(
            child: Column(
              children: [
                const Text(
                    "Select the Monika After Story .apk file. This APK has to be from the developer \"ale4ever\", and can be obtained from"),
                TextButton(
                  onPressed: () async {
                    await openUrl(_masDiscordChatUrl);
                  },
                  child: const Text("Discord"),
                ),
                const Text("or"),
                TextButton(
                  onPressed: () async {
                    await openUrl(_telegramBotUrl);
                  },
                  child: const Text("Telegram"),
                ),
                if (_loadingData) const CircularProgressIndicator(),
                MaterialButton(
                  // when using async, => is not required
                  onPressed: !_loadingData ? _selectAPK : null,
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
              ],
            ),
          ),
        ),
        Step(
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 1,
          title: const Text("Select Mods"),
          content: Center(
            child: Column(
              children: [
                const Text(
                    "Select the mods (only .zip files) you want to apply"),
                if (_loadingData) const CircularProgressIndicator(),
                MaterialButton(
                  onPressed: _loadingData ? null : _selectMods,
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
              ],
            ),
          ),
        ),
        Step(
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 2,
          title: const Text("Add Mods"),
          content: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    const Text("Review data before continue:"),
                    const Text("APK:"),
                    Text(
                      _selectedAPK?.name == null
                          ? 'No APK??'
                          : _selectedAPK!.name.length > 30
                              ? "${_selectedAPK!.name.substring(0, 30)}..."
                              : _selectedAPK!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Mods:"),
                    Text(
                      _selectedMods
                          .map((mod) => mod.name.length > 30
                              ? "${mod.name.substring(0, 30)}..."
                              : mod.name)
                          .join("\n\n"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      onPressed: _loadingData ? null : _addMod,
                      color: theme.secondary,
                      textColor: Colors.white,
                      splashColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: const Text(
                        "Add Mods",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 18,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LinearProgressIndicator(
                          // below only works with values between 0 and 1
                          value: _getProgressValue(),
                          // valueColor: AlwaysStoppedAnimation(Colors.red),
                          backgroundColor: Colors.grey,
                        ),
                        Center(
                          child: Text(_modApplyProgress?.getCurrentStep() ??
                              "Press the button!"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Step(
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          isActive: _currentStep >= 3,
          title: const Text("Apply Gifts"),
          content: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    const Text(
                      "If you are trying to add custom gifts, you need to select"
                      "all the gifts to add. This is an optional step. Extracted gifts can be found"
                      " in the app home folder.",
                    ),
                    const SizedBox(height: 10),
                    ..._selectedCustomGifts
                        .map((gift) => Text(gift.name))
                        .toList(),
                    MaterialButton(
                      onPressed: _loadingData ? null : _selectCustomGifts,
                      color: theme.secondary,
                      textColor: Colors.white,
                      splashColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: const Text(
                        "Select Gifts",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    MaterialButton(
                      onPressed: _loadingData ? null : _applyCustomGifts,
                      color: theme.secondary,
                      textColor: Colors.white,
                      splashColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: const Text(
                        "Apply Gifts",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Step(
          isActive: _currentStep >= 4,
          title: const Text("Done"),
          content: Center(
            child: Column(
              children: [
                Text(
                  "The process has been completed. You can now sign the .apk file in ${_pathToApk ?? "N/A"}. "
                  "You need to sign the file with ZipSigner.\n",
                ),
                const Text(
                  "After signing the APK, you can install the game! Adding custom gifts has to happen inside "
                  "the mas game folder.\n",
                ),
                MaterialButton(
                  onPressed: () => {
                    setState(
                      () {
                        _currentStep = 0;
                        _selectedAPK = null;
                        _selectedMods = [];
                        _modApplyProgress = null;
                        _loadingData = false;
                        _pathToApk = null;
                      },
                    )
                  },
                  color: theme.secondary,
                  textColor: Colors.white,
                  splashColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/help");
            },
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      body: ListView(
        children: [
          Stepper(
            // allow ListView to work with Stepper
            physics: const ClampingScrollPhysics(),
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
                        onPressed:
                            !_loadingData ? _getNextStep(details, theme) : null,
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
                        onPressed: _currentStep < 1 || _loadingData
                            ? null
                            : details.onStepCancel,
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
        ],
      ),
    );
  }
}
