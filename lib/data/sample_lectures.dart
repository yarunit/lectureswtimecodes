import '../models/lecture.dart';

final sampleLectures = <Lecture>[
  Lecture(
    title: 'Linear Algebra, Lecture 4',
    date: DateTime(2026, 3, 18),
    length: Duration(minutes: 48),
    topics: [
      Topic(start: Duration(minutes: 0, seconds: 40), title: 'Vectors in the plane'),
      Topic(start: Duration(minutes: 4, seconds: 10), title: 'Linear combinations'),
      Topic(start: Duration(minutes: 8, seconds: 5), title: 'Span'),
      Topic(start: Duration(minutes: 12, seconds: 30), title: 'Linear independence'),
      Topic(start: Duration(minutes: 16, seconds: 20), title: 'Basis'),
      Topic(start: Duration(minutes: 20, seconds: 0), title: 'Dimension'),
      Topic(start: Duration(minutes: 24, seconds: 15), title: 'Matrices as maps'),
      Topic(start: Duration(minutes: 28, seconds: 40), title: 'Matrix multiplication'),
      Topic(start: Duration(minutes: 33, seconds: 5), title: 'Inverse'),
      Topic(start: Duration(minutes: 37, seconds: 25), title: 'Determinant'),
      Topic(start: Duration(minutes: 41, seconds: 10), title: 'Eigenvalues'),
      Topic(start: Duration(minutes: 44, seconds: 50), title: 'Where this shows up'),
    ],
  ),
  Lecture(
    title: 'Introduction to Databases',
    date: DateTime(2026, 3, 14),
    length: Duration(hours: 1, minutes: 12, seconds: 8),
    topics: [
      Topic(start: Duration(seconds: 42), title: 'Why normal form matters'),
      Topic(start: Duration(minutes: 8, seconds: 16), title: 'Primary key'),
      Topic(start: Duration(minutes: 21, seconds: 4), title: 'One-to-many relationship'),
    ],
  ),
  Lecture(
    title: 'A History of Interfaces',
    date: DateTime(2026, 3, 6),
    length: Duration(minutes: 36),
    topics: [
      Topic(start: Duration(seconds: 20), title: 'Command lines'),
      Topic(start: Duration(minutes: 9, seconds: 40), title: 'Windows and the mouse'),
      Topic(start: Duration(minutes: 18, seconds: 5), title: 'Touch'),
      Topic(start: Duration(minutes: 27, seconds: 30), title: 'What stayed the same'),
    ],
  ),
];
