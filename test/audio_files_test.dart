import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/audio_files.dart';

void main() {
  test('an opened file is copied into the app folder', () async {
    final source = File('${Directory.systemTemp.path}/sample_lecture.wav');
    await source.writeAsString('lecture-bytes');

    final stored = await copyAudioIntoApp(source.path);

    expect(stored, isNot(source.path));
    expect(stored, contains('sample_lecture.wav'));
    expect(await File(stored).readAsString(), 'lecture-bytes');

    await File(stored).delete();
    await source.delete();
  });
}