import '../globals.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image/image.dart';

import 'runffmpeg.dart';

bool generateMasks() {
  bool gotNewMasks = false;

  if (individualMasksEnabled) {
    for (SourceVideo vid in vids) {
      if (!vid.mask!.existsSync()) {
        vid.mask!.createSync();
        vid.mask!.writeAsBytesSync(
          encodePng(
            getSameBlack(getFirstFrame(vid)!),
          ),
        );
        gotNewMasks = true;
      }
    }
  } else if (subfolderMasksEnabled) {
    List<Directory> dirs = [];
    dirs.add(Directory.current);
    dirs.addAll(Directory.current.listSync(recursive: true).whereType<Directory>());

    for (String path in dirs.map((e) => e.path)) {
      if (!vids.any((element) => element.file.path.startsWith(path))) continue;

      File mask = File(path + ps + "mask.png");
      if (mask.existsSync())
        continue;
      else
        gotNewMasks = true;

      mask.createSync();
      mask.writeAsBytesSync(
        encodePng(
          getSameBlack(getFirstFrame(
            vids.firstWhere(
              (element) => element.file.path.startsWith(path),
            ),
          )!),
        ),
      );
    }
  } else {
    if (!maskFile.existsSync()) {
      File(maskFile.path).createSync();
      maskFile.writeAsBytesSync(
        encodePng(
          getSameBlack(
            getFirstFrame(vids.first)!,
          ),
        ),
      );
      gotNewMasks = true;
    }
  }

  return gotNewMasks;
}

Image getSameBlack(Image originalImg) {
  List<int> blackBytes =
      List<int>.generate(originalImg.width * originalImg.height * 3, (_) => 0);

  return Image.fromBytes(originalImg.width, originalImg.height, blackBytes,
      format: Format.rgb);
}

Image? currentMask;
String? currentMaskPath;
String? perviousMaskPath;
Image? getMasked(Image? original, SourceVideo video) {
  if (!maskEnabled) return original;

  if (individualMasksEnabled) {
    currentMaskPath = video.mask!.path;
  } else if (subfolderMasksEnabled) {
    currentMaskPath = dirname(video.file.path) + ps + "mask.png";
  } else {
    currentMaskPath = maskFile.path;
  }

  if (currentMaskPath != perviousMaskPath) {
    if (!File(currentMaskPath!).existsSync()) {
      currentMask = getSameBlack(getFirstFrame(video)!);
      print(
          "Couldn't find mask for ${video.file.path}! Assuming no mask. Restart the program to recreate blank mask(s).");
    } else
      currentMask = decodePng(video.mask!.readAsBytesSync());
  }
  perviousMaskPath = currentMaskPath;

  return original! + currentMask!; //'Image' makes this stupidly easy <3
}

/*
! old way of masking per file
TODO removeme

void applyMasks(SourceVideo vid) async {
  Image mask = decodePng(individualMasksEnabled
      ? vid.mask.readAsBytesSync()
      : maskFile.readAsBytesSync());

  int index = 1;
  await for (File frameFile in tempDir.list()) {
    File((frameFile.path)).writeAsBytesSync(
        encodePng(decodePng(frameFile.readAsBytesSync()) + mask));

    if (index % 50 == 0) print('  - ' + index.toString() + ' frames');
    index++;
  }
}
*/