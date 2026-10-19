import 'package:just_audio/just_audio.dart';

Future<Duration> readAudioLength(String path) async {
  final player = AudioPlayer();
  try {
    final duration = await player.setFilePath(path);
    if (duration == null || duration.inMilliseconds <= 0) {
      return const Duration(seconds: 1);
    }
    return duration;
  } catch (_) {
    return const Duration(seconds: 1);
  } finally {
    await player.dispose();
  }
}
