import 'dart:math' as math;
import 'dart:typed_data';

import 'models/lecture.dart';

class SpeechSegment {
  const SpeechSegment({required this.start, required this.end, required this.text});

  final Duration start;
  final Duration end;
  final String text;
}

class SpeechSpan {
  const SpeechSpan({required this.start, required this.end});

  final Duration start;
  final Duration end;
}

const _topicGap = Duration(seconds: 8);

/// Loudness windows on 16 kHz mono PCM. A quiet stretch of 8 seconds splits topics,
/// because the speech model often glues the pause into the previous timestamp.
List<SpeechSpan> spansFromPcm(Uint8List bytes, {int sampleRate = 16000}) {
  const windowMs = 100;
  final window = sampleRate * windowMs ~/ 1000;
  final sampleCount = bytes.length ~/ 2;
  final windows = sampleCount ~/ window;
  if (windows == 0) return const [];

  final data = ByteData.sublistView(bytes);
  final quiet = List<bool>.filled(windows, false);
  for (var w = 0; w < windows; w++) {
    var sum = 0.0;
    final base = w * window;
    for (var i = 0; i < window; i++) {
      final sample = data.getInt16((base + i) * 2, Endian.little);
      sum += sample * sample;
    }
    quiet[w] = math.sqrt(sum / window) < 400;
  }

  final quietWindows = _topicGap.inMilliseconds ~/ windowMs;
  final spans = <SpeechSpan>[];
  var speechStart = -1;
  var quietRun = 0;
  for (var w = 0; w < windows; w++) {
    if (quiet[w]) {
      quietRun += 1;
      if (speechStart >= 0 && quietRun >= quietWindows) {
        final endWindow = w - quietRun + 1;
        spans.add(SpeechSpan(start: _at(speechStart), end: _at(endWindow)));
        speechStart = -1;
      }
    } else {
      speechStart = speechStart < 0 ? w : speechStart;
      quietRun = 0;
    }
  }
  if (speechStart >= 0) {
    spans.add(SpeechSpan(start: _at(speechStart), end: _at(windows)));
  }
  return spans;
}

Duration _at(int window) => Duration(milliseconds: window * 100);

List<Topic> topicsFromSpeech(List<SpeechSegment> segments, {List<SpeechSpan> spans = const []}) {
  final kept = segments
      .map((segment) => SpeechSegment(start: segment.start, end: segment.end, text: _clean(segment.text)))
      .where((segment) => segment.text.isNotEmpty)
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  if (kept.isEmpty) {
    return const [Topic(start: Duration.zero, title: 'Start')];
  }

  if (spans.length > 1) {
    return _topicsOnSpans(kept, spans);
  }

  final groups = <List<SpeechSegment>>[];
  var current = <SpeechSegment>[kept.first];
  for (final segment in kept.skip(1)) {
    final previous = current.last;
    final gap = segment.start - previous.end;
    if (gap >= _topicGap) {
      groups.add(current);
      current = [segment];
    } else {
      current.add(segment);
    }
  }
  groups.add(current);

  return [
    for (final group in groups) Topic(start: group.first.start, title: _title(group.first.text)),
  ];
}

List<Topic> _topicsOnSpans(List<SpeechSegment> segments, List<SpeechSpan> spans) {
  final topics = <Topic>[];
  for (final span in spans) {
    SpeechSegment? first;
    for (final segment in segments) {
      if (_nearest(segment.start, spans) != span) continue;
      first ??= segment;
    }
    if (first == null) continue;
    final start = first.start < span.start ? span.start : first.start;
    topics.add(Topic(start: start, title: _title(first.text)));
  }
  if (topics.isEmpty) {
    return const [Topic(start: Duration.zero, title: 'Start')];
  }
  return topics;
}

SpeechSpan _nearest(Duration time, List<SpeechSpan> spans) {
  var best = spans.first;
  var bestGap = (time - best.start).abs();
  for (final span in spans.skip(1)) {
    final gap = (time - span.start).abs();
    if (gap < bestGap) {
      best = span;
      bestGap = gap;
    }
  }
  return best;
}

String _clean(String text) {
  return text.replaceAll(RegExp(r'\[[^\]]*\]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _title(String text) {
  final sentence = text.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
  final words = sentence.isEmpty ? text : sentence;
  if (words.length <= 72) return words;
  return '${words.substring(0, 69).trim()}...';
}
