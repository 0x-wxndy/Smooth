import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Linux desktop has no reliable in-app video_player backend without heavy native deps.
/// Copy the bundled asset to a temp file and open it with the system player.
abstract final class LessonVideoLauncher {
  static bool isFilePath(String ref) {
    if (ref.startsWith('/')) return true;
    if (ref.length > 2 && ref[1] == ':') return true;
    return ref.contains('course_media');
  }

  static Future<String> resolvePlayablePath(String videoRef) async {
    if (isFilePath(videoRef)) return videoRef;
    return materializeAsset(videoRef);
  }

  static Future<String> materializeAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'smooth_lessons', p.basename(assetPath)));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    return file.path;
  }

  static Future<void> openInSystemPlayer(String filePath) async {
    final commands = <List<String>>[
      ['mpv', '--keep-open=yes', filePath],
      ['vlc', filePath],
      ['xdg-open', filePath],
    ];

    for (final parts in commands) {
      final bin = parts.first;
      if (!_commandExists(bin)) continue;
      try {
        await Process.start(
          bin,
          parts.sublist(1),
          mode: ProcessStartMode.detached,
        );
        return;
      } catch (_) {
        continue;
      }
    }

    throw StateError(
      'No video player found. Install mpv (`sudo apt install mpv`) or vlc, then try again.',
    );
  }

  static bool _commandExists(String name) {
    if (name.contains('/')) return File(name).existsSync();
    for (final dir in (Platform.environment['PATH'] ?? '').split(':')) {
      if (dir.isEmpty) continue;
      final file = File(p.join(dir, name));
      if (file.existsSync()) return true;
    }
    return false;
  }
}
