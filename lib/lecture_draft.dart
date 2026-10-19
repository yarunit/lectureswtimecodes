import 'format.dart';
import 'models/lecture.dart';

Lecture recordedLecture(Duration length, DateTime now) {
  final safe = length.inSeconds < 1 ? const Duration(seconds: 1) : length;
  return Lecture(
    title: 'Lecture, ${formatDate(now)}',
    date: DateTime(now.year, now.month, now.day),
    length: safe,
    topics: const [Topic(start: Duration.zero, title: 'Start')],
  );
}

Lecture lectureFromFile({
  required String path,
  required Duration length,
  required DateTime now,
}) {
  final safe = length.inSeconds < 1 ? const Duration(seconds: 1) : length;
  return Lecture(
    title: titleFromPath(path),
    date: DateTime(now.year, now.month, now.day),
    length: safe,
    audioPath: path,
    topics: const [Topic(start: Duration.zero, title: 'Start')],
  );
}

String titleFromPath(String path) {
  final name = path.split(RegExp(r'[/\\]')).last;
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return name;
  return name.substring(0, dot);
}
