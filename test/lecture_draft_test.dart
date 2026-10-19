import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/lecture_draft.dart';

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
}
