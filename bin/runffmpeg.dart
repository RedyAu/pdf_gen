import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'globals.dart';
import 'utils.dart';

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
              '%06d$extractedFramesExtension'
            ],
            //runInShell: true,
            workingDirectory: canonicalize(tempDir.path),
            stderrEncoding: utf8)
        .stderr;
  } catch (e) {
    print(
        "Couldn't extract frames! Is ffmpeg installed?\nGet help at: https://www.wikihow.com/Install-FFmpeg-on-Windows");
    terminate();
  }
}