import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart';
import 'package:path/path.dart';
import '../globals.dart';
import '../utils/utils.dart';

Future<String> runFFMPEG(SourceVideo vid) async {
  try {
    return Process.runSync(
            'ffmpeg',
            [
              '-i',
              canonicalize(vid.file.path),
              '-vf',
              'select=not(mod(n\\,$extractEveryNthFrame))',
              '-vsync',
              'vfr',
              '%06d.png'
            ],
            //runInShell: true,
            workingDirectory: canonicalize(tempDir.path),
            stderrEncoding: utf8)
        .stderr;
  } catch (e) {
    print(
        "Couldn't extract frames! Is ffmpeg installed?\nGet help at: https://www.wikihow.com/Install-FFmpeg-on-Windows");
    terminate();
    return ""; //Just to make intellisense happy
  }
}

Image getFirstFrame(SourceVideo vid) {
  String framename = basenameWithoutExtension(vid.file.path) + '_first.png';

  String ffmpegLog;
  try {
    ffmpegLog = Process.runSync('ffmpeg',
            ['-i', canonicalize(vid.file.path), '-vframes', '1', '$framename'],
            workingDirectory: canonicalize(dirname(vid.file.path)),
            stderrEncoding: utf8)
        .stderr;
  } catch (e) {
    print(
        "Couldn't extract first frame! Is ffmpeg installed?\nGet help at: https://www.wikihow.com/Install-FFmpeg-on-Windows");
    terminate();
  }

  File frameFile = File(dirname(vid.file.path) + ps + framename);

  if (!frameFile.existsSync()) {
    print(
        "Couldn't extract first frame! This was the ffmpeg log:\n" + ffmpegLog);
    terminate();
  }

  Image frame = decodeImage(frameFile.readAsBytesSync());
  frameFile.delete();
  return frame;
}
