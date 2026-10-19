import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio_files.dart';
import 'audio_length.dart';
import 'data/sample_lectures.dart';
import 'lecture_draft.dart';
import 'lecture_store.dart';
import 'models/lecture.dart';
import 'screens/add_lecture_sheet.dart';
import 'screens/empty_screen.dart';
import 'screens/lecture_screen.dart';
import 'screens/library_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/record_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const LecturesApp());
}

class LecturesApp extends StatelessWidget {
  const LecturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lectures',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      onGenerateRoute: (settings) {
        if (settings.name == '/processing') {
          final lecture = settings.arguments! as Lecture;
          return MaterialPageRoute(builder: (_) => ProcessingScreen(lecture: lecture));
        }
        if (settings.name == '/lecture') {
          final lecture = settings.arguments! as Lecture;
          return MaterialPageRoute(builder: (_) => LectureScreen(lecture: lecture));
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = LectureStore();
  final _added = <Lecture>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _store.load();
    if (!mounted || saved.isEmpty) return;
    setState(() {
      _added
        ..clear()
        ..addAll(saved);
    });
  }

  List<Lecture> get _lectures => [..._added, ...sampleLectures];

  Future<void> _add() async {
    final choice = await showAddLectureSheet(context);
    if (!mounted || choice == null) return;
    if (choice == AddChoice.record) {
      await _record();
    } else {
      await _openFile();
    }
  }

  Future<void> _record() async {
    final outputPath = await newRecordingPath();
    if (!mounted) return;
    final clip = await Navigator.of(context).push<RecordedClip>(
      MaterialPageRoute(builder: (_) => RecordScreen(outputPath: outputPath)),
    );
    if (!mounted || clip == null) return;
    final length = await _lengthOf(clip.path, clip.length);
    if (!mounted) return;
    _openNew(recordedLecture(length, DateTime.now(), audioPath: clip.path));
  }

  Future<void> _openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
    );
    final path = result?.files.single.path;
    if (!mounted || path == null) return;
    final stored = await copyAudioIntoApp(path);
    final length = await readAudioLength(stored);
    if (!mounted) return;
    _openNew(lectureFromFile(path: stored, length: length, now: DateTime.now(), title: titleFromPath(path)));
  }

  Future<Duration> _lengthOf(String? path, Duration fallback) async {
    if (path == null) return fallback;
    final read = await readAudioLength(path);
    if (read.inSeconds <= 1 && fallback > read) return fallback;
    return read;
  }

  void _openNew(Lecture lecture) {
    setState(() => _added.insert(0, lecture));
    unawaited(_store.save(_added));
    Navigator.of(context).pushNamed('/processing', arguments: lecture);
  }

  @override
  Widget build(BuildContext context) {
    if (_lectures.isEmpty) {
      return EmptyScreen(onAdd: _add);
    }
    return LibraryScreen(
      lectures: _lectures,
      onOpen: (lecture) => Navigator.of(context).pushNamed('/lecture', arguments: lecture),
      onAdd: _add,
    );
  }
}
