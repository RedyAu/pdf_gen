import 'package:image/image.dart';
import 'package:diff_image/diff_image.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'globals.dart';

bool tipShown = false;

Future<List<Frame>> chooseFrames(String ffmpegOutput) async {
  print(' 2.1. Getting file list...');
  List<Frame> frames = List<Frame>();
  for (File file in tempDir.listSync().where((element) =>
      element is File && extension(element.path) == extractedFramesExtension))
    frames.add(Frame(file, int.parse(basenameWithoutExtension(file.path))));
  frames.sort((a, b) => a.index.compareTo(b.index));
  if (frames.length == 0) {
    print(
        "Error! There were no frames extracted. Skipping this video. This was the FFMPEG log:\n" +
            ffmpegOutput.toString());
    return null;
  }

  print(" 2.2. Comparing " +
      frames.length.toString() +
      " frames... This may take a while.");
  if (!tipShown) {
    print(
        "TIP: The program checks for existing .pdf files, you can stop it and continue next time from the video file you stopped it at (extracted frames and difference checking progress don't get saved.)");
    tipShown = true;
  }
  List<Frame> toKeep = List<Frame>();
  int index = 1 + chooserBeginTransitionLength;
  toKeep.add(frames[index]);
  while (true) {
    double diff = DiffImage.compareFromMemory(
            decodeImage(frames[index - 1].file.readAsBytesSync()),
            decodeImage(frames[index].file.readAsBytesSync()))
        .diffValue;

    if (index % 50 == 0)
      print('  - ' +
          index.toString() +
          '/' +
          frames.length.toString() +
          ' frames');

    if (diff > chooserFidelity) {
      index += chooserTransitionLength;
      if (index + 1 > frames.length) index = frames.length - 1;

      toKeep.add(frames[index]);
    } else {
      index++;
      if (index + 1 > frames.length) break;
    }
  }

  return toKeep;
}