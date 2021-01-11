import 'dart:convert';

import 'package:image/image.dart';
import 'package:diff_image/diff_image.dart';
import 'dart:io';
import 'package:path/path.dart';

//! CONFIG
final String extractedFramesExtension = "bmp";
final int extractEveryNthFrame = 10;
final double chooserFidelity = 0.1;
final int chooserSelectAfter = 2;

//Globals
List<SourceVideo> vids = List<SourceVideo>();
List<String> videoExtensions = ['.mp4', '.avi', '.mov'];

void main() async {
  print('PDF-GEN\n\nInitializing...');
  //TODO create folders if they don't exist
  Directory rootDir = Directory(r'PDF-GEN');
  Directory vidDir = Directory(r'PDF-GEN\_Source Videos');
  Directory tempDir = Directory(r'PDF-GEN\TEMP');

  print('Getting source videos...');
  // Get source videos
  for (FileSystemEntity file in vidDir.listSync(recursive: true).where(
      (element) =>
          videoExtensions.any((ext) => extension(element.path) == ext))) {
    vids.add(SourceVideo(file, basename(file.path)));
  }
  if (vids.isEmpty)
    print('No videos found! Are they the right format? (mp4, avi, mov)');

  // Loop through videos
  for (SourceVideo vid in vids) {
    print(
        '1/3 Extracting frames... This may take much time and hard disk space.');
    await Process.run(
        'ffmpeg',
        [
          '-i',
          canonicalize(vid.file.path),
          '-vf',
          'select=not(mod(n\\,$extractEveryNthFrame))',
          '-vsync',
          'vfr',
          'frame_%06d.$extractedFramesExtension'
        ],
        //runInShell: true,
        workingDirectory: canonicalize(tempDir.path),
        stderrEncoding: utf8);

    print('2/3 Choosing unique frames...');
    //TODO choose frames

    print('3/3 Exporting pdf...');
    //TODO compile pdf

    //TODO cleanup
    print(vid.name + ' is done! ----------------------------\n\n');
  }
}

class SourceVideo {
  final File file;
  final String name;

  SourceVideo(this.file, this.name);
}

class Frame {
  File file;
  int index;

  Frame(this.file, this.index);
}
