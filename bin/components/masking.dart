import '../globals.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image/image.dart';

import 'runffmpeg.dart';

bool generateMasks() {
  bool gotNewMasks = false;

  if (individualMasksEnabled) {
    for (SourceVideo vid in vids) {
      if (!vid.mask.existsSync()) {
        File(vid.mask.path).createSync();
        vid.mask.writeAsBytesSync(encodePng(getSameBlack(getFirstFrame(vid))));
        gotNewMasks = true;
      }
    }
  } else {
    if (!maskFile.existsSync()) {
      File(maskFile.path).createSync();
      maskFile
          .writeAsBytesSync(encodePng(getSameBlack(getFirstFrame(vids.first))));
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
