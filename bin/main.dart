import 'dart:io';
import 'package:path/path.dart';
import 'components/masking.dart';
import 'utils/default_config.dart';
import 'globals.dart';
import 'utils/initialize.dart';
import 'utils/utils.dart';
import 'components/framechooser.dart';
import 'components/createpdf.dart';
import 'components/runffmpeg.dart';

final debug = false;
void main() async {
  if (debug)
    await program();
  else {
    try {
      await program();
    } catch (e, s) {
      print("\n\nThere was an error while running the program!");
      print("$e\n\n$s");

      print("\n\n-------\nPress Enter to exit.");
      stdin.readByteSync();
      exit(0);
    }
  }
}

Future program() async {
  print(
      'PDF-GEN $softwareVersion\nWritten by RedyAu in 2021-2022\n\nInitializing...');
  await initialize();

  print('Getting source videos...\n\n');
  // Get source 
  for (File file in Directory.current
      .listSync(recursive: true)
      .whereType<File>()
      .where((element) =>
          videoExtensions.any((ext) => extension(element.path) == ext))) {
    vids.add(
      SourceVideo(
        file,
        File(withoutExtension(file.path) + "_mask" + ".png"),
      ),
    );
  }
  if (vids.isEmpty) {
    print('No videos found! Are they the right format? (mp4, avi, mov)');
    terminate();
  }
  if (maskEnabled) {
    if (generateMasks()) {
      if (individualMasksEnabled) {
        print(
            'Generating a blank mask beside each video file. Draw white shapes on them, where you want the content of the frames to be deleted.');
      } else if (subfolderMasksEnabled) {
        print(
            'Generating a blank mask in each subfolder. Draw white shapes on it, where you want the content of the frames to be deleted.');
      } else {
        print(
            'Generating a blank mask (mask.png). Draw white shapes on it, where you want the content of the frames to be deleted.');
      }
      terminate();
    }
  }

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
      index++;
      continue;
    }

    clearTemp();

    print(
        '1. Extracting frames... This may take a while, and consume much disk space.');
    String? ffmpegOutput = await runFFMPEG(vid);

/*
! old way of applying masks to each file
TODO removeme
    if (maskEnabled) {
      print('2. Applying masks... This may take a while.');
      await applyMasks(vid);
    }
*/
    print('2. Choosing unique frames...');
    List<Frame>? keepFrames = await chooseFrames(ffmpegOutput, vid);
    if (keepFrames == null || keepFrames.length == 0) {
      print(
          'Error! There were no frames marked to keep. Processing next video... \n');
      index++;
      continue;
    }

    print('3. Exporting pdf...');
    await createPdf(keepFrames, withoutExtension(vid.file.path) + ".pdf");

    print('Done!\n\n');
    index++;
  }

  print("\n\nGoodbye!");
  terminate();
}