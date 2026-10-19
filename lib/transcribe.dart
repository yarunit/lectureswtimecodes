import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_kit/download_model.dart';
import 'package:whisper_kit/whisper_kit.dart';

import 'audio_wav.dart';
import 'models/lecture.dart';
import 'topics.dart';

Future<List<Topic>> findTopics(String path, {void Function(String status)? onStatus}) async {
  onStatus?.call('Finding topics');
  final wav = await wavForTranscription(path);
  debugPrint('wav bytes ${File(wav).lengthSync()}');
  try {
    final support = await getApplicationSupportDirectory();
    final model = WhisperModel.tiny;
    final modelPath = model.getPath(support.path);
    if (!File(modelPath).existsSync()) {
      onStatus?.call('Downloading the speech model');
      await downloadModel(
        model: model,
        destinationPath: support.path,
        onDownloadProgress: (received, total) {
          if (total <= 0 || received < total) {
            onStatus?.call('Downloading the speech model');
          }
        },
      );
    }
    onStatus?.call('Finding topics');
    // compute sends only the two paths. A closure here also captures the
    // async completer of findTopics, and the isolate refuses to start.
    final decoded = await compute(_transcribe, (wav, modelPath));
    debugPrint('whisper text ${(decoded['text'] as String?)?.length} segments ${(decoded['segments'] as List?)?.length}');
    if (decoded['text'] == null) {
      throw StateError(decoded['message']?.toString() ?? 'Could not read this lecture');
    }
    final result = WhisperTranscribeResponse.fromJson(decoded);
    debugPrint('transcript: ${result.text}');
    final segments = [
      for (final segment in result.segments ?? const <WhisperTranscribeSegment>[])
        SpeechSegment(start: segment.fromTs, end: segment.toTs, text: segment.text),
    ];
    return topicsFromSpeech(segments, spans: _spans(wav));
  } catch (error, stack) {
    debugPrint('topics failed: $error\n$stack');
    rethrow;
  } finally {
    if (wav != path) {
      final file = File(wav);
      if (file.existsSync()) file.deleteSync();
    }
  }
}

List<SpeechSpan> _spans(String wavPath) {
  final bytes = File(wavPath).readAsBytesSync();
  final pcm = bytes.length > 44 && bytes[0] == 0x52 && bytes[1] == 0x49 ? bytes.sublist(44) : bytes;
  return spansFromPcm(Uint8List.fromList(pcm));
}

Map<String, dynamic> _transcribe((String, String) paths) {
  final wavPath = paths.$1;
  final modelPath = paths.$2;
  final lib = DynamicLibrary.open('libwhisper.so');
  final request = lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('request');
  final release = lib.lookupFunction<Void Function(Pointer<Utf8>), void Function(Pointer<Utf8>)>('whisper_kit_free');
  final body = jsonEncode({
    '@type': 'getTextFromWavFile',
    'audio': wavPath,
    'model': modelPath,
    'is_translate': false,
    'threads': 4,
    'is_verbose': false,
    'language': 'auto',
    'is_special_tokens': false,
    'is_no_timestamps': false,
    'n_processors': 1,
    'split_on_word': false,
    'no_fallback': false,
    'diarize': false,
    'speed_up': false,
  });
  final nativeBody = body.toNativeUtf8();
  final response = request(nativeBody);
  malloc.free(nativeBody);
  if (response == nullptr) {
    throw StateError('Could not read this lecture');
  }
  final text = response.toDartString();
  release(response);
  return jsonDecode(text) as Map<String, dynamic>;
}
