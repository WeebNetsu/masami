import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  Future<Directory?> _getAppDir() async {
    var dirs = await getExternalStorageDirectories();
    if (dirs == null || dirs.isEmpty) return null;

    return dirs[0];
  }

  Future<File?> _saveFilePermanently(PlatformFile file,
      [String? newFileName]) async {
    var appDir = await _getAppDir();

    if (appDir == null) return null;

    final newFile = await File("${appDir.path}/tmp/${newFileName ?? file.name}")
        .create(recursive: true);

    return File(file.path!).copy(newFile.path);
  }

  Future<Directory?> _extractZip(
      PlatformFile originalFile, String newFileName) async {
    // below gives similar to /data/user/0/com.weebnetsu.masami/app_flutter
    // below will rename the file and save it in our app directory
    var extractFile = await _saveFilePermanently(originalFile, newFileName);

    if (extractFile == null) return null;

    // Use an InputFileStream to access the zip file without storing it in memory.
    final inputStream = InputFileStream(extractFile.path);
    // Decode the zip from the InputFileStream. The archive will have the contents of the
    // zip, without having stored the data in memory.
    final archive = ZipDecoder().decodeBuffer(inputStream);
    // final appStorage = await getApplicationDocumentsDirectory()
    // await extractFileToDisk(originalFile!.path!, '${appStorage.path}/mod');
    for (var file in archive.files) {
      // If it's a file and not a directory
      if (file.isFile) {
        // Write the file content to a directory called 'out'.
        // In practice, you should make sure file.name doesn't include '..' paths
        // that would put it outside of the extraction directory.
        // An OutputFileStream will write the data to disk.
        final outputStream =
            OutputFileStream('${extractFile.parent.path}/${file.name}');
        // The writeContent method will decompress the file content directly to disk without
        // storing the decompressed data in memory.
        file.writeContent(outputStream);
        // Make sure to close the output stream so the File is closed.
        outputStream.close();
      }
    }

    await extractFile.delete(recursive: true);

    return extractFile.parent;
  }

  /// Will rename a file
  Future<File> _renameFile(String newName, File file) async {
    String dir = path.dirname(file.path);
    String newPath = path.join(dir, newName);
    return await file.rename(newPath);
  }

  Future<Directory> _renameFolder(String newName, Directory folder) async {
    String dir = path.dirname(folder.path);
    String newPath = path.join(dir, newName);
    return await folder.rename(newPath);
  }

  Future<bool> _cleanDataDir() async {
    var appDir = await _getAppDir();

    if (appDir == null) return true;

    final tmpDir = Directory("${appDir.path}/tmp");
    final tmpDirExists = await tmpDir.exists();

    if (tmpDirExists) {
      try {
        await tmpDir.delete(recursive: true);
        // if it throws an error, directory could not be deleted
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  Future<void> _addMod() async {
    var cleanedDataDir = await _cleanDataDir();
    // todo show error instead of returning immediately
    if (!cleanedDataDir) return;

    // we extract mods first, since there will be more and a higher change of error
    // todo show error instead of returning immediately
    if (_selectedMods.isEmpty) return;

    print(_selectedMods);

    Directory? extractedModsDir;
    for (var file in _selectedMods) {
      Directory? extractedMod = await _extractZip(file, "mod/${file.name}");

      if (extractedMod == null) return;
      print("${file.name} extracted");

      extractedModsDir ??= extractedMod;
    }

    if (extractedModsDir == null) return;

    print("Mods extracted");

    if (_selectedAPK == null) return;

    Directory? extractedApkDir =
        await _extractZip(_selectedAPK!, "apk/mas.zip");

    // todo show error instead
    if (extractedApkDir == null) return;
    print("APK extracted");

    print("Start renaming mods");
    for (FileSystemEntity mod in extractedModsDir.listSync()) {
      if (mod is Directory) {
        for (FileSystemEntity modInner in mod.listSync()) {
          if (modInner is Directory) {
            var curDirName = modInner.path.split("/").last;
            switch (curDirName) {
              case "game":
                var newDirName = await _renameFolder("x-game", modInner);
                print(newDirName.path);
                break;
              default:
            }
          }
        }
      }
    }
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
          title: const Text("Add Mods"),
          content: Center(
            child: MaterialButton(
              onPressed: _addMod,
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
          isActive: _currentStep >= 3,
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
                "Done",
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
        // todo: uncomment below, it was just commented out for testing
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
