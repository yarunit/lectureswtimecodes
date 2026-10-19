import 'dart:async';

import 'package:flutter/material.dart';

import '../format.dart';
import '../models/lecture.dart';
import '../theme/app_theme.dart';

class LectureScreen extends StatefulWidget {
  const LectureScreen({super.key, required this.lecture});

  final Lecture lecture;

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  Duration _position = Duration.zero;
  bool _playing = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.lecture.topics.isNotEmpty) {
      _position = widget.lecture.topics.first.start;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_playing || !mounted) return;
      final next = _position + const Duration(seconds: 1);
      setState(() {
        _position = next > widget.lecture.length ? widget.lecture.length : next;
        if (_position >= widget.lecture.length) _playing = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Topic? get _current {
    Topic? current;
    for (final topic in widget.lecture.topics) {
      if (topic.start <= _position) current = topic;
    }
    return current;
  }

  void _seek(Duration position) {
    final max = widget.lecture.length;
    setState(() {
      if (position < Duration.zero) {
        _position = Duration.zero;
      } else if (position > max) {
        _position = max;
      } else {
        _position = position;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lecture = widget.lecture;
    final ink = Theme.of(context).colorScheme.onSurface;
    final remaining = lecture.length - _position;
    final progress = lecture.length.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / lecture.length.inMilliseconds;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
          children: [
            Text(
              '${formatDate(lecture.date).toUpperCase()} · ${formatLength(lecture.length).toUpperCase()}',
              style: AppTheme.label(context),
            ),
            const SizedBox(height: 8),
            Text(lecture.title, style: AppTheme.serif(context, 44, height: 0.98)),
            const SizedBox(height: 22),
            _PlayerCard(
              position: _position,
              total: lecture.length,
              remaining: remaining,
              progress: progress,
              playing: _playing,
              onToggle: () => setState(() => _playing = !_playing),
              onSeek: _seek,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text('Topics', style: AppTheme.serif(context, 28)),
                const Spacer(),
                Text(
                  '${lecture.topics.length} sections',
                  style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final topic in lecture.topics)
              _TopicRow(
                topic: topic,
                active: topic == _current,
                onTap: () => _seek(topic.start),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.position,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.playing,
    required this.onToggle,
    required this.onSeek,
  });

  final Duration position;
  final Duration total;
  final Duration remaining;
  final double progress;
  final bool playing;
  final VoidCallback onToggle;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    final accent = Theme.of(context).brightness == Brightness.dark ? AppColors.mint : AppColors.green;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(formatClock(position), style: TextStyle(color: ink.withValues(alpha: 0.55), fontSize: 13)),
              const Spacer(),
              Text(formatTotal(total), style: TextStyle(color: ink.withValues(alpha: 0.55), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: accent,
              inactiveTrackColor: ink.withValues(alpha: 0.12),
              thumbColor: accent,
            ),
            child: Slider(
              value: progress.clamp(0, 1),
              onChanged: (value) => onSeek(total * value),
            ),
          ),
          Row(
            children: [
              Text('1×', style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 14)),
              const Spacer(),
              Material(
                color: accent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggle,
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: Icon(playing ? Icons.pause : Icons.play_arrow, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '-${formatClock(remaining)}',
                style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.active, required this.onTap});

  final Topic topic;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    final accent = Theme.of(context).brightness == Brightness.dark ? AppColors.mint : AppColors.green;
    final color = active ? accent : ink;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ink.withValues(alpha: 0.08))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text(formatClock(topic.start), style: TextStyle(color: active ? accent : ink.withValues(alpha: 0.45))),
            ),
            Expanded(
              child: Text(
                topic.title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (active) Icon(Icons.graphic_eq, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}
