import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> audioDirectory() async {
  Directory root;
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    root = Directory.systemTemp;
  } else {
    try {
      root = await getApplicationDocumentsDirectory();
    } catch (_) {
      root = Directory.systemTemp;
    }
  }
  final directory = Directory('${root.path}/audio');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  return directory;
}

Future<String> newRecordingPath() async {
  final directory = await audioDirectory();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  return '${directory.path}/recording_$stamp.m4a';
}

Future<String> copyAudioIntoApp(String sourcePath) async {
  try {
    final directory = await audioDirectory();
    final name = sourcePath.split(RegExp(r'[/\\]')).last;
    final destination = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$name');
    await File(sourcePath).copy(destination.path);
    return destination.path;
  } catch (_) {
    return sourcePath;
  }
}
