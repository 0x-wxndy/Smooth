import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class CourseMediaHelper {
  static Future<String?> pickCoverImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return _copyToCourseMedia(File(path), 'cover');
  }

  static Future<String?> pickIntroVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return _copyToCourseMedia(File(path), 'video');
  }

  static Future<String> _copyToCourseMedia(File source, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'course_media'));
    if (!mediaDir.existsSync()) {
      await mediaDir.create(recursive: true);
    }
    final ext = p.extension(source.path);
    final dest = File(
      p.join(mediaDir.path, '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext'),
    );
    await source.copy(dest.path);
    return dest.path;
  }

  static String fileName(String path) => p.basename(path);
}
