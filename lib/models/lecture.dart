class Topic {
  const Topic({required this.start, required this.title});

  final Duration start;
  final String title;
}

class Lecture {
  const Lecture({
    required this.title,
    required this.date,
    required this.length,
    required this.topics,
    this.audioPath,
  });

  final String title;
  final DateTime date;
  final Duration length;
  final List<Topic> topics;
  final String? audioPath;

  Lecture copyWith({List<Topic>? topics}) {
    return Lecture(
      title: title,
      date: date,
      length: length,
      topics: topics ?? this.topics,
      audioPath: audioPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'lengthMs': length.inMilliseconds,
      'audioPath': audioPath,
      'topics': [
        for (final topic in topics) {'startMs': topic.start.inMilliseconds, 'title': topic.title},
      ],
    };
  }

  factory Lecture.fromJson(Map<String, dynamic> json) {
    final topics = (json['topics'] as List<dynamic>).map((item) {
      final topic = item as Map<String, dynamic>;
      return Topic(
        start: Duration(milliseconds: topic['startMs'] as int),
        title: topic['title'] as String,
      );
    }).toList();
    return Lecture(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      length: Duration(milliseconds: json['lengthMs'] as int),
      topics: topics,
      audioPath: json['audioPath'] as String?,
    );
  }
}
