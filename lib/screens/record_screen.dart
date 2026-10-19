import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../format.dart';
import '../theme/app_theme.dart';
import '../widgets/back_circle.dart';

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
  bool _released = false;
  bool _microphoneFailed = false;
  late final Future<void> _starting;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_recording) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    _starting = _begin();
  }

  Future<void> _begin() async {
    try {
      final allowed = await _recorder.hasPermission();
      if (!allowed || !mounted || _closed) {
        _markMicrophoneFailed();
        return;
      }
      try {
        final session = await AudioSession.instance;
        await session.setActive(true);
      } catch (_) {
        // Recording can still start if the session is already active.
      }
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 44100,
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.mic,
            speakerphone: true,
          ),
        ),
        path: widget.outputPath,
      );
      if (!mounted || _closed) {
        await _recorder.stop();
        _markMicrophoneFailed();
        return;
      }
      setState(() => _recording = true);
    } catch (_) {
      _markMicrophoneFailed();
    }
  }

  void _markMicrophoneFailed() {
    _recording = false;
    if (!mounted) return;
    setState(() => _microphoneFailed = true);
  }

  Future<String?> _finish({required bool keep}) async {
    if (_released) return null;
    _released = true;
    await _starting;
    if (!_recording) {
      if (!keep) await _delete(widget.outputPath);
      await _recorder.dispose();
      return null;
    }
    _recording = false;
    try {
      final path = await _recorder.stop();
      if (!keep && path != null) await _delete(path);
      await _recorder.dispose();
      return keep ? path : null;
    } catch (_) {
      await _recorder.dispose();
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
    if (path == null) {
      Navigator.of(context).pop();
      return;
    }
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
    if (!_released) unawaited(_finish(keep: false));
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
              BackCircle(onPressed: _cancel),
              const SizedBox(height: 18),
              Text('RECORDING', style: AppTheme.label(context)),
              const SizedBox(height: 10),
              Text('New lecture', style: AppTheme.serif(context, 48)),
              const Spacer(),
              Center(child: Text(formatClock(_elapsed), style: AppTheme.serif(context, 84, height: 1))),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _microphoneFailed ? 'Microphone is not available' : 'Tap stop when the lecture ends',
                  textAlign: TextAlign.center,
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
