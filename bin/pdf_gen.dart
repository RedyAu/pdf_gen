import 'dart:io';
import 'package:path/path.dart';
import 'default_config.dart';
import 'globals.dart';
import 'utils.dart';
import 'framechooser.dart';
import 'createpdf.dart';
import 'runffmpeg.dart';

void main() async {
  try {
    print(
        'PDF-GEN $softwareVersion\nWritten by RedyAu in 2021\n\nInitializing...');
    await initialize();

    print('Getting source videos...\n\n');
    // Get source videos
    for (FileSystemEntity file in vidDir.listSync(recursive: true).where(
        (element) =>
            videoExtensions.any((ext) => extension(element.path) == ext))) {
      vids.add(SourceVideo(file, basename(file.path)));
    }
    if (vids.isEmpty)
      print('No videos found! Are they the right format? (mp4, avi, mov)');

    // Loop through videos
    int index = 1;
    for (SourceVideo vid in vids) {
      print(index.toString() +
          '/' +
          vids.length.toString() +
          ' videos: ' +
          basename(vid.file.path) +
          '\n');

      if (File(withoutExtension(vid.file.path) + ".pdf").existsSync()) {
        print('PDF already exists!\n\n');
        continue;
      }

      clearTemp();

      print(
          '1. Extracting frames... This may take a while, and consume much disk space.');
      String ffmpegOutput = await runFFMPEG(vid);

      print('2. Choosing unique frames...');
      var keepFrames = await chooseFrames(ffmpegOutput);
      if (keepFrames == null) continue;

      print('3. Exporting pdf...');
      await createPdf(keepFrames, withoutExtension(vid.file.path) + ".pdf");

      print('Done!\n\n');
      index++;
    }

    print("\n\nGoodbye!");
    terminate();
    //-----------------------
  } catch (e) {
    print("\n\nThere was an error while running the program!");
    print(e);

    print("\n\n-------\nPress Enter to exit.");
    stdin.readByteSync();
    exit(0);
  }
}

Future<bool> initialize() async {
  if (!vidDir.existsSync()) {
    new Directory(vidDir.path).createSync(recursive: true);
    print(
        "Created folder for source videos. Place videos in any folder structure inside and relaunch the program.");
  }
  if (!tempDir.existsSync())
    new Directory(tempDir.path).createSync(recursive: true);

  if (!configFile.existsSync()) {
    new File(configFile.path).writeAsStringSync(defaultConfig);
    print(
        "Created config file with default settings. Please edit them and relaunch the program.");
    terminate();
  } else {
    List<String> configLines = configFile.readAsLinesSync();

    extractEveryNthFrame =
        int.parse(getConfigValue(configLines, "- Extract every Nth frame: "));

    extractedFramesExtension =
        getConfigValue(configLines, "- Extracted frames extension: ");

    chooserFidelity = double.parse(
        getConfigValue(configLines, "- Percentage treshold for new slide: "));

    chooserBeginTransitionLength = int.parse(
        getConfigValue(configLines, "- Intro transition lenth in frames: "));

    chooserTransitionLength = int.parse(getConfigValue(
        configLines, "- Transition length between slides in frames: "));

    jpgQuality =
        int.parse(getConfigValue(configLines, "- JPG quality of slides: "));
  }
}
