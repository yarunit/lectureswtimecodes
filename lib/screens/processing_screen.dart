import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lecture.dart';
import '../theme/app_theme.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.lecture});

  final Lecture lecture;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/lecture', arguments: widget.lecture);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW LECTURE', style: AppTheme.label(context)),
              const SizedBox(height: 10),
              Text(widget.lecture.title, style: AppTheme.serif(context, 46, height: 0.98)),
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
              Center(child: Text('Finding topics', style: AppTheme.serif(context, 32))),
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
