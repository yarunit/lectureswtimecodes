import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models/lecture.dart';

class LectureStore {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/lectures.json');
  }

  Future<List<Lecture>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [
        for (final item in decoded) Lecture.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // The sample list still opens if the file cannot be read.
      return [];
    }
  }

  Future<void> save(List<Lecture> lectures) async {
    try {
      final file = await _file();
      final encoded = jsonEncode([for (final lecture in lectures) lecture.toJson()]);
      await file.writeAsString(encoded);
    } catch (_) {
      // The new lecture stays on screen even if the file cannot be written.
    }
  }
}
