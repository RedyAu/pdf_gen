import 'package:image/image.dart';
import 'package:image_compare/image_compare.dart';
import 'dart:io';
import 'package:path/path.dart';
import '../globals.dart';
import 'masking.dart';

bool tipShown = false;

Future<List<Frame>?> chooseFrames(
    String? ffmpegOutput, SourceVideo sourceVideo) async {
  print(' 3.1. Getting file list...');
  List<Frame> frames = [];
  for (File file in tempDir.listSync() as Iterable<File>)
    frames.add(Frame(file, int.parse(basenameWithoutExtension(file.path))));
  frames.sort((a, b) => a.index.compareTo(b.index));
  if (frames.length == 0) {
    print(
        "Error! There were no frames extracted. Skipping this video. This was the FFMPEG log:\n" +
            ffmpegOutput.toString());
    return null;
  }

  print(" 3.2. Comparing " +
      frames.length.toString() +
      " frames... This may take a while.");
  if (!tipShown) {
    print(
        "TIP: The program checks for existing .pdf files, you can stop it and continue next time from the video file you stopped it at (extracted frames and difference checking progress don't get saved.)");
    tipShown = true;
  }
  if (frames.length - (chooserIntroFrameCount + chooserOutroFrameCount) <= 0) {
    print(
        'Error! Specified intro and outro length is longer than the video.\nKeep in mind, you have to enter actually extracted frame count, not duration. Continuing without ignoring them.');
  } else {
    try {
      frames = frames.sublist(chooserIntroFrameCount + 1,
          (frames.length - chooserOutroFrameCount) - 1);
    } catch (e) {
      print(
          'Error while ignoring intro and outro. Continuing without ignoring them.\nError was: $e');
    }
  }

  List<Frame> toKeep = [];
  int index = 0;
  toKeep.add(frames[index]);

  Image? currentFrame;
  Image? nextFrame;

  currentFrame =
      getMasked(decodePng(frames.first.file.readAsBytesSync()), sourceVideo);

  while (true) {
    nextFrame = decodePng(frames[index + 1].file.readAsBytesSync());

    double diff = await compareImages(
        src1: currentFrame!.getBytes(),
        src2: nextFrame!.getBytes(),
        algorithm: PerceptualHash());

    currentFrame = nextFrame;

    if (index % 50 == 0)
      print('  - ' +
          index.toString() +
          '/' +
          frames.length.toString() +
          ' frames');

    if (diff > chooserFidelity) {
      index += chooserTransitionFrameCount;

      toKeep.add(frames[(index >= frames.length) ? frames.length - 1 : index]);
    } else {
      index++;
    }

    if (index + 1 >= frames.length) break;
  }

  return toKeep;
}
