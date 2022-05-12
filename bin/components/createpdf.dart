import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart';
import 'dart:io';
import '../globals.dart';

Future createPdf(List<Frame> frames, String path) async {
  final pdf = pw.Document();

  for (Frame frame in frames) {
    var rawFrame = encodeJpg(decodeImage(frame.file.readAsBytesSync())!,
        quality: jpgQuality);
    var decodedFrame = decodeImage(rawFrame)!;

    final image = pw.MemoryImage(rawFrame as Uint8List);
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(
            decodedFrame.width.toDouble(), decodedFrame.height.toDouble(),
            marginAll: 0),
        build: (pw.Context context) => pw.Image(image)));
  }

  final file = File(path);
  file.writeAsBytesSync(await pdf.save());
  return;
}
