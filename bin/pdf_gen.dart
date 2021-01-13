import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart';
import 'package:diff_image/diff_image.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'default_config.dart';
import 'package:http/http.dart' as http;

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

void main() async {
  try {
    print('PDF-GEN\nWritten by RedyAu in 2021\n\nInitializing...');
    await initialize();

    print('Getting source videos...\n\n');
    // Get source videos
    for (FileSystemEntity file in vidDir.listSync(recursive: true).where(
        (element) =>
            videoExtensions.any((ext) => extension(element.path) == ext))) {
      vids.add(SourceVideo(file, basename(file.path)));
    }
    if (vids.isEmpty)
      print('No videos found! Are they the right format? (mp4, avi, mov)');

    // Loop through videos
    int index = 1;
    for (SourceVideo vid in vids) {
      print(index.toString() +
          '/' +
          vids.length.toString() +
          ' videos: ' +
          basename(vid.file.path) +
          '\n');

      if (File(withoutExtension(vid.file.path) + ".pdf").existsSync()) {
        print('PDF already exists!\n\n');
        continue;
      }

      clearTemp();

      print(
          '1. Extracting frames... This may take a while, and consume much disk space.');
      String ffmpegOutput = await runFFMPEG(vid);

      print('2. Choosing unique frames...');
      var keepFrames = await chooseFrames(ffmpegOutput);

      print('3. Exporting pdf...');
      await createPdf(keepFrames, withoutExtension(vid.file.path) + ".pdf");

      print('Done!\n\n');
      index++;
    }

    print("\n\nGoodbye!");
    terminate();
    //-----------------------
  } catch (e) {
    print("\n\nThere was an error while running the program!");
    print(e);

    print("\n\n-------\nPress Enter to exit.");
    stdin.readByteSync();
    exit(0);
  }
}

void terminate() {
  clearTemp();

  print("\n\n-------\nPress Enter to exit.");
  stdin.readByteSync();
  exit(0);
}

void clearTemp() {
  for (var entity in tempDir
      .listSync()
      .where((item) => extension(item.path) != ".exe")) entity.deleteSync();
}

Future<bool> initialize() async {
  if (!vidDir.existsSync()) {
    new Directory(vidDir.path).createSync(recursive: true);
    print(
        "Created folder for source videos. Place videos in any folder structure inside and relaunch the program.");
  }
  if (!tempDir.existsSync())
    new Directory(tempDir.path).createSync(recursive: true);

  if (!configFile.existsSync()) {
    new File(configFile.path).writeAsStringSync(defaultConfig);
    print(
        "Created config file with default settings. Please edit them and relaunch the program.");
    terminate();
  } else {
    List<String> configLines = configFile.readAsLinesSync();

    extractEveryNthFrame =
        int.parse(getConfigValue(configLines, "- Extract every Nth frame: "));

    extractedFramesExtension =
        getConfigValue(configLines, "- Extracted frames extension: ");

    chooserFidelity = double.parse(
        getConfigValue(configLines, "- Percentage treshold for new slide: "));

    chooserBeginTransitionLength = int.parse(
        getConfigValue(configLines, "- Intro transition lenth in frames: "));

    chooserTransitionLength = int.parse(getConfigValue(
        configLines, "- Transition length between slides in frames: "));

    jpgQuality =
        int.parse(getConfigValue(configLines, "- JPG quality of slides: "));
  }
}

String getConfigValue(List<String> configLines, String key) {
  //Calling this a key is a bit of a stretch but hey, this isn't open source (oh wait)
  return configLines
      .firstWhere((element) => element.startsWith(key))
      .split(": ")[1];
}

void createPdf(List<Frame> frames, String path) async {
  final pdf = pw.Document();

  for (Frame frame in frames) {
    var rawFrame = encodeJpg(decodeImage(frame.file.readAsBytesSync()),
        quality: jpgQuality);
    var decodedFrame = decodeImage(rawFrame);

    final image = pw.MemoryImage(rawFrame);
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(
            decodedFrame.width.toDouble(), decodedFrame.height.toDouble(),
            marginAll: 0),
        build: (pw.Context context) => pw.Image(image)));
  }

  final file = File(path);
  await file.writeAsBytesSync(await pdf.save());
}

bool tipShown = false;

Future<List<Frame>> chooseFrames(String ffmpegOutput) async {
  print(' 2.1. Getting file list...');
  List<Frame> frames = List<Frame>();
  for (File file in tempDir.listSync().where((element) =>
      element is File && extension(element.path) == extractedFramesExtension))
    frames.add(Frame(file, int.parse(basenameWithoutExtension(file.path))));
  frames.sort((a, b) => a.index.compareTo(b.index));
  if (frames.length == 0) {
    print("Error! There were no frames extracted. This was the FFMPEG log:\n" +
        ffmpegOutput.toString());
  }

  print(" 2.2. Comparing frames... This may take a while.");
  if (!tipShown) {
    print(
        "TIP: The program checks for existing .pdf files, you can stop it and continue next time from the video file you stopped it at (extracted frames and difference checking progress don't get saved.)");
    tipShown = true;
  }
  List<Frame> toKeep = List<Frame>();
  int index = 1 + chooserBeginTransitionLength;
  toKeep.add(frames[index]);
  while (true) {
    double diff = DiffImage.compareFromMemory(
            decodeImage(frames[index - 1].file.readAsBytesSync()),
            decodeImage(frames[index].file.readAsBytesSync()))
        .diffValue;

    if (index % 50 == 0)
      print('  - ' +
          index.toString() +
          '/' +
          frames.length.toString() +
          ' frames');

    if (diff > chooserFidelity) {
      index += chooserTransitionLength;
      if (index + 1 > frames.length) index = frames.length - 1;

      toKeep.add(frames[index]);
    } else {
      index++;
      if (index + 1 > frames.length) break;
    }
  }

  return toKeep;
}

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
        "A konvertálás nem sikerült! Telepítve van az ffmpeg?\nHa nincs: https://www.wikihow.com/Install-FFmpeg-on-Windows");
    terminate();
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
