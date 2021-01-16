import 'dart:io';
import 'package:path/path.dart';
import '../globals.dart';

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

String getConfigValue(List<String> configLines, String key) {
  //Calling this a key is a bit of a stretch but hey, this isn't open source (oh wait)
  return configLines
      .firstWhere((element) => element.startsWith(key), orElse: () => ": ")
      .split(": ")[1];
}
