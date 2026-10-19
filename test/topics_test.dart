import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/topics.dart';

void main() {
  test('one phrase becomes one topic', () {
    final topics = topicsFromSpeech(const [
      SpeechSegment(start: Duration(seconds: 3), end: Duration(seconds: 8), text: 'Vectors and matrices.'),
    ]);

    expect(topics, hasLength(1));
    expect(topics.single.start, const Duration(seconds: 3));
    expect(topics.single.title, 'Vectors and matrices.');
  });

  test('a long pause starts a new topic', () {
    final topics = topicsFromSpeech(const [
      SpeechSegment(start: Duration.zero, end: Duration(seconds: 4), text: 'Today we cover vectors.'),
      SpeechSegment(start: Duration(seconds: 5), end: Duration(seconds: 9), text: 'A matrix is a grid.'),
      SpeechSegment(start: Duration(seconds: 20), end: Duration(seconds: 25), text: 'Databases store tables.'),
    ]);

    expect(topics.map((topic) => topic.title).toList(), [
      'Today we cover vectors.',
      'Databases store tables.',
    ]);
    expect(topics[1].start, const Duration(seconds: 20));
  });

  test('silence markers are dropped', () {
    final topics = topicsFromSpeech(const [
      SpeechSegment(start: Duration.zero, end: Duration(seconds: 1), text: '[BLANK_AUDIO]'),
      SpeechSegment(start: Duration(seconds: 2), end: Duration(seconds: 6), text: ' [Music] Hello there.'),
    ]);

    expect(topics.single.title, 'Hello there.');
  });

  test('a quiet stretch splits topics even when timestamps touch', () {
    final spans = spansFromPcm(_lectureWithAPause());
    expect(spans, hasLength(2));

    final topics = topicsFromSpeech(const [
      SpeechSegment(start: Duration.zero, end: Duration(seconds: 11), text: 'Today we cover vectors and matrices.'),
      SpeechSegment(start: Duration(seconds: 11), end: Duration(seconds: 13), text: 'Databases store tables and keys.'),
    ], spans: spans);

    expect(topics.map((topic) => topic.title).toList(), [
      'Today we cover vectors and matrices.',
      'Databases store tables and keys.',
    ]);
    expect(topics[1].start.inSeconds, greaterThanOrEqualTo(10));
  });

  test('no speech leaves the start marker', () {
    final topics = topicsFromSpeech(const [
      SpeechSegment(start: Duration.zero, end: Duration(seconds: 1), text: '[BLANK_AUDIO]'),
    ]);

    expect(topics.single.title, 'Start');
    expect(topics.single.start, Duration.zero);
  });
}

Uint8List _lectureWithAPause() {
  const rate = 16000;
  final samples = <int>[
    for (var i = 0; i < rate ~/ 2; i++) i.isEven ? 8000 : -8000,
    for (var i = 0; i < rate * 9; i++) 0,
    for (var i = 0; i < rate ~/ 2; i++) i.isEven ? 8000 : -8000,
  ];
  final bytes = Uint8List(samples.length * 2);
  final data = ByteData.sublistView(bytes);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(i * 2, samples[i], Endian.little);
  }
  return bytes;
}
