import 'package:flutter/material.dart';

import '../models/lecture.dart';
import '../theme/app_theme.dart';
import '../transcribe.dart';
import '../widgets/back_circle.dart';

class PendingLecture {
  const PendingLecture({required this.lecture, required this.onUpdated});

  final Lecture lecture;
  final ValueChanged<Lecture> onUpdated;
}

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.pending});

  final PendingLecture pending;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _status = 'Finding topics';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    var lecture = widget.pending.lecture;
    final path = lecture.audioPath;
    if (path != null) {
      try {
        final topics = await findTopics(path, onStatus: _setStatus);
        lecture = lecture.copyWith(topics: topics);
      } catch (_) {
        // The lecture still opens. Topics stay at the start marker.
      }
    }
    widget.pending.onUpdated(lecture);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/lecture', arguments: lecture);
  }

  void _setStatus(String status) {
    if (!mounted || status == _status) return;
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackCircle(),
              const SizedBox(height: 18),
              Text('NEW LECTURE', style: AppTheme.label(context)),
              const SizedBox(height: 10),
              Text(widget.pending.lecture.title, style: AppTheme.serif(context, 46, height: 0.98)),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 148,
                  height: 148,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 148,
                        height: 148,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.green,
                          backgroundColor: Color(0xFFD9DDD6),
                        ),
                      ),
                      Icon(Icons.graphic_eq, color: ink.withValues(alpha: 0.8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Center(child: Text(_status, style: AppTheme.serif(context, 32))),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'this takes a couple of minutes',
                  style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 16),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  "You can leave this screen. We'll keep\nworking in the background.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ink.withValues(alpha: 0.4), fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
