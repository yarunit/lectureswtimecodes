import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../format.dart';
import '../theme/app_theme.dart';

class RecordedClip {
  const RecordedClip({required this.length, this.path});

  final Duration length;
  final String? path;
}

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.outputPath});

  final String outputPath;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _recorder = AudioRecorder();
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _recording = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    unawaited(_begin());
  }

  Future<void> _begin() async {
    try {
      final allowed = await _recorder.hasPermission();
      if (!allowed || !mounted || _closed) return;
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: widget.outputPath,
      );
      if (!mounted || _closed) {
        await _recorder.stop();
        return;
      }
      _recording = true;
    } catch (_) {
      _recording = false;
    }
  }

  Future<String?> _finish({required bool keep}) async {
    if (!_recording) {
      if (!keep) await _delete(widget.outputPath);
      return null;
    }
    _recording = false;
    try {
      final path = await _recorder.stop();
      if (!keep && path != null) await _delete(path);
      return keep ? path : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _finish(keep: true);
    if (!mounted) return;
    Navigator.of(context).pop(RecordedClip(length: _elapsed, path: path));
  }

  Future<void> _cancel() async {
    _closed = true;
    _timer?.cancel();
    await _finish(keep: false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _closed = true;
    _timer?.cancel();
    if (_recording) unawaited(_recorder.stop());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _cancel,
                  icon: Icon(Icons.close, color: ink.withValues(alpha: 0.7)),
                ),
              ),
              Text('RECORDING', style: AppTheme.label(context)),
              const SizedBox(height: 10),
              Text('New lecture', style: AppTheme.serif(context, 48)),
              const Spacer(),
              Center(child: Text(formatClock(_elapsed), style: AppTheme.serif(context, 84, height: 1))),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap stop when the lecture ends',
                  style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 16),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _stop,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Stop', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
