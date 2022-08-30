import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Get application directory in Android folder, similar to
/// /data/user/0/com.weebnetsu.masami/app_flutter
Future<Directory?> getAppDir() async {
  var dirs = await getExternalStorageDirectories();
  if (dirs == null || dirs.isEmpty) return null;

  return dirs[0];
}

/// Will rename a file
Future<File> renameFile(String newName, File file) async {
  String dir = path.dirname(file.path);
  String newPath = path.join(dir, newName);
  return await file.rename(newPath);
}

/// Will rename a folder
Future<Directory> renameFolder(String newName, Directory folder) async {
  String dir = path.dirname(folder.path);
  String newPath = path.join(dir, newName);
  return await folder.rename(newPath);
}

/// Get directories required by app, if one of the directories are not found, will
/// return an empty Map
Future<Map<String, Directory>> getExistingAppDirs() async {
  final appDir = await getAppDir();
  if (appDir == null) return {};

  final tmpDir = Directory("${appDir.path}/tmp");

  // these are the main directories we'll be working with
  final directories = {
    'apk': Directory("${tmpDir.path}/apk"),
    'mod': Directory("${tmpDir.path}/mod"),
    "tmp": tmpDir,
  };

  for (Directory dir in directories.values) {
    final exists = await dir.exists();
    if (!exists) return {};
  }

  return directories;
}

/// This will save a file in the /data/user/0/com.weebnetsu.masami/ directory, this
/// will copy the file from the cache directory if it is there. Returns the new `File`
Future<File?> saveFilePermanently(PlatformFile file,
    [String? newFileName]) async {
  var appDir = await getAppDir();

  if (appDir == null) return null;

  final newFile = await File("${appDir.path}/tmp/${newFileName ?? file.name}")
      .create(recursive: true);

  return File(file.path!).copy(newFile.path);
}

/// Extracts a .zip file and returns the **parent** directory of the extracted file
Future<Directory?> extractZip(
    PlatformFile originalFile, String newFileName) async {
  // below gives similar to /data/user/0/com.weebnetsu.masami/app_flutter
  // below will rename the file and save it in our app directory
  var extractFile = await saveFilePermanently(originalFile, newFileName);

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

/// Will compress the APK files into a .zip file
Future<File?> createMASZip() async {
  Map<String, Directory> dirs = await getExistingAppDirs();

  if (dirs.isEmpty) return null;

  Directory? apkDir = dirs["apk"];
  Directory? tmpDir = dirs["tmp"];

  if (apkDir == null || tmpDir == null) return null;

  String zipFileName = "${tmpDir.path}/mas.zip";

  var encoder = ZipFileEncoder();
  encoder.zipDirectory(apkDir, filename: zipFileName);

  File zipFile = File(zipFileName);
  bool zipExists = await zipFile.exists();

  if (!zipExists) return null;

  return zipFile;
}

/// Will delete all files and folders in the /tmp directory in our app directory
Future<bool> cleanDataDir() async {
  final appDir = await getAppDir();

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

/// Will rename all files and folders in File or Directory passed in
Future<bool> recursiveRename(FileSystemEntity item) async {
  String curItemName = item.path.split("/").last;

  if (item is File) {
    await renameFile("x-$curItemName", item);
    return true;
  }

  if (item is Directory) {
    var newGameDir = await renameFolder("x-$curItemName", item);

    for (FileSystemEntity innerItem in newGameDir.listSync()) {
      var renameSuccess = await recursiveRename(innerItem);

      if (!renameSuccess) return false;
    }
  }

  // not sure if I should really be returning true here...
  return true;
}

/// This will copy a directory and all items inside it to designated location
///
/// Will not copy duplicates of directories called **x-game**
Future<void> copyDir(Directory dir, String location) async {
  for (FileSystemEntity item in dir.listSync()) {
    String moverName = item.path.split("/").last;
    String movedName = "$location/$moverName";

    if (item is File) {
      await File(movedName).create();
      item.copy(movedName);
      continue;
    }

    if (item is Directory) {
      bool xGameFound = false;
      List<String> newMovedNameList = [];
      // remove x-game from path if it already exists in path
      for (String loc in movedName.split("/")) {
        if (loc == "x-game") {
          if (xGameFound) {
            continue;
          } else {
            xGameFound = true;
          }
        }

        newMovedNameList.add(loc);
      }

      String newMovedName = newMovedNameList.join("/");

      if (item.path.split("/").last == "x-game") {
        await copyDir(item, newMovedName);
      } else {
        await Directory(newMovedName).create();
        await copyDir(item, newMovedName);
      }
    }
  }
}

/// Copy all mod files to extracted APK directory
Future<bool> applyModFiles() async {
  Map<String, Directory> dirs = await getExistingAppDirs();

  if (dirs.isEmpty) return false;

  Directory? apkDir = dirs["apk"];
  Directory? modDir = dirs["mod"];

  if (apkDir == null || modDir == null) return false;

  Directory apkGameDir =
      await Directory("${apkDir.path}/assets/x-game").create(recursive: true);

  List<Directory> modDirs = [];
  for (FileSystemEntity mod in modDir.listSync()) {
    if (mod is Directory) modDirs.add(mod);
  }

  for (Directory mod in modDirs) {
    await copyDir(mod, apkGameDir.path);
  }

  // not sure if I should really be returning true here...
  return true;
}
