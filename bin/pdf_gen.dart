import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart';
import 'package:diff_image/diff_image.dart';
import 'dart:io';
import 'package:path/path.dart';

//! CONFIG
final int extractEveryNthFrame = 20;
final double chooserFidelity = 0.1;
final int chooserTransitionLength = 2;
final int chooserBeginTransitionLength = 2;
final int jpgQuality = 60;

//Globals
final String extractedFramesExtension = ".bmp";
final List<String> videoExtensions = ['.mp4', '.avi', '.mov'];

final Directory rootDir = Directory(r'PDF-GEN');
final Directory vidDir = Directory(r'PDF-GEN\_Source Videos');
final Directory tempDir = Directory(r'PDF-GEN\TEMP');
List<SourceVideo> vids = List<SourceVideo>();

void main() async {
  print('PDF-GEN\n\nInitializing...');
  if (!vidDir.existsSync())
    new Directory(vidDir.path).createSync(recursive: true);
  if (!tempDir.existsSync())
    new Directory(tempDir.path).createSync(recursive: true);

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

    print(
        '1. Extracting frames... This may take much time and hard disk space.');
    await runFFMPEG(vid);

    print('2. Choosing unique frames...');
    var keepFrames = await chooseFrames();

    print('3. Exporting pdf...');
    await createPdf(keepFrames, withoutExtension(vid.file.path) + ".pdf");

    for (var entity in tempDir.listSync()) entity.deleteSync();
    print('------------------- Done! -------------------\n\n');
    index++;
  }
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

Future<List<Frame>> chooseFrames() async {
  print(' 2.1. Getting file list...');
  List<Frame> frames = List<Frame>();
  for (File file in tempDir.listSync().where((element) =>
      element is File && extension(element.path) == extractedFramesExtension))
    frames.add(Frame(file, int.parse(basenameWithoutExtension(file.path))));
  frames.sort((a, b) => a.index.compareTo(b.index));

  print(' 2.2. Comparing frames... This may take a while.');
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

void runFFMPEG(SourceVideo vid) async {
  await Process.run(
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
      stderrEncoding: utf8);
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
