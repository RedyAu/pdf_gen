import 'dart:io';

//Configurables
int extractEveryNthFrame;
String extractedFramesExtension = "";
double chooserFidelity;
int chooserTransitionLength;
int chooserBeginTransitionLength;
int jpgQuality;

//Globals
final List<String> videoExtensions = ['.mp4', '.avi', '.mov'];

final Directory rootDir = Directory(r'PDF-GEN');
final Directory vidDir = Directory(r'PDF-GEN\_Source Videos');
final Directory tempDir = Directory(r'PDF-GEN\TEMP');
final File configFile = File(r'PDF-GEN\config.txt');
List<SourceVideo> vids = List<SourceVideo>();
final String softwareVersion = "b0.1";

//Types
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
