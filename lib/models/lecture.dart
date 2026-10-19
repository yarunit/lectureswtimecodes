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
  });

  final String title;
  final DateTime date;
  final Duration length;
  final List<Topic> topics;
}
