import 'package:flutter/services.dart';

const _channel = MethodChannel('com.vanya630.lectureswtimecodes/audio');

Future<String> wavForTranscription(String path) async {
  final converted = await _channel.invokeMethod<String>('toWav', {'path': path});
  if (converted == null || converted.isEmpty) {
    throw StateError('Could not read this audio file');
  }
  return converted;
}
