import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class PublicationMediaHelper {
  static Future<List<String>> pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null) return [];
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'publication_media'));
    if (!mediaDir.existsSync()) {
      await mediaDir.create(recursive: true);
    }
    final paths = <String>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      final ext = p.extension(path);
      final dest = File(
        p.join(mediaDir.path, 'img_${DateTime.now().millisecondsSinceEpoch}_${paths.length}$ext'),
      );
      await File(path).copy(dest.path);
      paths.add(dest.path);
    }
    return paths;
  }
}