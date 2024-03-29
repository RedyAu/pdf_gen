import 'dart:io';

import '../globals.dart';
import 'default_config.dart';
import 'utils.dart';

Future initialize() async {
/*
TODO removeme
   if (!vidDir.existsSync()) {
    Directory(vidDir.path).createSync(recursive: true);
    print(
        "Created folder for source videos. Place videos in any folder structure inside and relaunch the program.");
  } */
  if (!tempDir.existsSync())
    Directory(tempDir.path).createSync(recursive: true);

  if (!configFile.existsSync()) {
    File(configFile.path).writeAsStringSync(defaultConfig);
    print(
        "Created config file with default settings. Please edit them and relaunch the program.");
    terminate();
  } else {
    List<String> configLines = configFile.readAsLinesSync();

    if (getConfigValue(configLines, "Generated by version: ") !=
        softwareVersion) {
      print(
          'Config file generated by previous version. Creating new file, backing up old.\nPlease edit new file and restart the program.');

      configFile.renameSync(configFile.path + '.old');
      configFile.writeAsStringSync(defaultConfig);
      terminate();
    }

    extractEveryNthFrame =
        int.parse(getConfigValue(configLines, "- Extract every Nth frame: "));

    maskEnabled = getConfigValue(configLines, "- Use a mask: ") == "true";

    individualMasksEnabled =
        getConfigValue(configLines, "- Use unique mask for each video: ") ==
            "true";

    subfolderMasksEnabled =
        getConfigValue(configLines, "- Use unique mask for each video: ") ==
            "true";

    chooserFidelity = double.parse(
        getConfigValue(configLines, "- Percentage treshold for new slide: "));

    chooserIntroFrameCount = int.parse(
        getConfigValue(configLines, "- Intro transition length in frames: "));

    chooserOutroFrameCount = int.parse(
        getConfigValue(configLines, "- Outro transition length in frames: "));

    chooserTransitionFrameCount = int.parse(getConfigValue(
        configLines, "- Transition length between slides in frames: "));

    jpgQuality =
        int.parse(getConfigValue(configLines, "- JPG quality of slides: "));
  }
}
