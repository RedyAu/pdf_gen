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
final String ps = Platform.pathSeparator;
final Directory rootDir = Directory('PDF-GEN');
final Directory vidDir = Directory('PDF-GEN' + ps + '_Source Videos');
final Directory tempDir = Directory('PDF-GEN' + ps + 'TEMP');
final File configFile = File('PDF-GEN' + ps + 'config.txt');
final File maskFile = File('PDF-GEN' + ps + 'mask.png');
List<SourceVideo> vids = List<SourceVideo>();
final String softwareVersion = "1.0";

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
