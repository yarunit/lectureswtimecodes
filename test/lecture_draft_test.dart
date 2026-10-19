import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/lecture_draft.dart';
import 'package:lectureswtimecodes/models/lecture.dart';

void main() {
  test('file name becomes the lecture title', () {
    final lecture = lectureFromFile(
      path: '/tmp/Linear Algebra.wav',
      length: const Duration(seconds: 20),
      now: DateTime(2026, 10, 19),
    );

    expect(lecture.title, 'Linear Algebra');
    expect(lecture.audioPath, '/tmp/Linear Algebra.wav');
    expect(lecture.length, const Duration(seconds: 20));
    expect(lecture.date, DateTime(2026, 10, 19));
  });

  test('a saved lecture keeps its file path', () {
    final lecture = lectureFromFile(
      path: '/tmp/Linear Algebra.wav',
      length: const Duration(seconds: 20),
      now: DateTime(2026, 10, 19),
    );

    final copy = Lecture.fromJson(lecture.toJson());

    expect(copy.title, lecture.title);
    expect(copy.audioPath, lecture.audioPath);
    expect(copy.length, lecture.length);
    expect(copy.topics.single.title, 'Start');
    expect(copy.topics.single.start, Duration.zero);
  });

  test('a recording keeps the audio path', () {
    final lecture = recordedLecture(
      const Duration(seconds: 12),
      DateTime(2026, 10, 19),
      audioPath: '/tmp/recording.m4a',
    );

    expect(lecture.audioPath, '/tmp/recording.m4a');
    expect(lecture.length, const Duration(seconds: 12));
  });
}
