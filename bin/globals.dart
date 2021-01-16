import 'dart:io';
import 'package:image/image.dart';

//Configurables
int extractEveryNthFrame;
double chooserFidelity;
int chooserTransitionLength;
int chooserBeginTransitionLength;
int jpgQuality;
bool maskEnabled;
bool individualMasksEnabled;
int maskWidth;
int maskHeight;

//Globals
final List<String> videoExtensions = ['.mp4', '.avi', '.mov'];

final Directory rootDir = Directory(r'PDF-GEN');
final Directory vidDir = Directory(r'PDF-GEN\_Source Videos');
final Directory tempDir = Directory(r'PDF-GEN\TEMP');
final File configFile = File(r'PDF-GEN\config.txt');
final File maskFile = File(r'PDF-GEN\mask.png');
List<SourceVideo> vids = List<SourceVideo>();
final String softwareVersion = "b0.2";

//Types
class SourceVideo {
  final File file;
  final File mask;

  SourceVideo(this.file, [this.mask]);
}

class Frame {
  final File file;
  final int index;
  Image data;

  Frame(this.file, this.index, [this.data]);
}
