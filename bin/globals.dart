import 'dart:io';

//Configurables
int? extractEveryNthFrame;
late double chooserFidelity;
late int chooserTransitionFrameCount;
late int chooserIntroFrameCount;
late int chooserOutroFrameCount;
late int jpgQuality;
bool maskEnabled = false;
bool subfolderMasksEnabled = false;
bool individualMasksEnabled = false;
int? maskWidth;
int? maskHeight;

//Globals
final List<String> videoExtensions = [
  //! If you need a format supported by ffmpeg and not listed here, create an issue or open a PR!
  '.mp4',
  '.avi',
  '.mov',
  '.wmv',
  '.flv',
  '.m4v',
  '.mov',
  '.mp4',
  '.m4a',
  '.3gp',
  '.3g2',
  '.mj2',
  '.mpeg',
  '.mp2'
];

final String ps = Platform.pathSeparator;
//final Directory rootDir = Directory('PDF-GEN');
//final Directory vidDir = Directory('PDF-GEN' + ps + '_Source Videos');
final Directory tempDir =
    Directory(Directory.systemTemp.path + ps + "frames_temp");
final File configFile = File('config.txt');
final File maskFile = File('mask.png');
List<SourceVideo> vids = [];
final String softwareVersion = "2.0.1"; //TODO update me

//Types
class SourceVideo {
  final File file;
  final File? mask;

  SourceVideo(this.file, [this.mask]);
}

class Frame {
  final File file;
  final int index;

  Frame(this.file, this.index);
}
