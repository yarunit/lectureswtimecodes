import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/sample_lectures.dart';
import 'models/lecture.dart';
import 'screens/empty_screen.dart';
import 'screens/lecture_screen.dart';
import 'screens/library_screen.dart';
import 'screens/processing_screen.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _add(BuildContext context) {
    Navigator.of(context).pushNamed('/processing', arguments: sampleLectures[1]);
  }

  @override
  Widget build(BuildContext context) {
    if (sampleLectures.isEmpty) {
      return EmptyScreen(onAdd: () => _add(context));
    }
    return LibraryScreen(
      lectures: sampleLectures,
      onOpen: (lecture) => Navigator.of(context).pushNamed('/lecture', arguments: lecture),
      onAdd: () => _add(context),
    );
  }
}
