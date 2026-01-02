import 'dart:io';

/// Script to check file sizes and identify files that need splitting
/// Usage: dart scripts/check_file_sizes.dart
void main() async {
  const maxLines = 300;
  final featuresDir = Directory('lib/features');

  if (!await featuresDir.exists()) {
    return;
  }

  final largeFiles = <FileInfo>[];

  await for (final entity in featuresDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final lines = await _countLines(entity);
      if (lines > maxLines) {
        largeFiles.add(FileInfo(entity.path, lines));
      }
    }
  }

  if (largeFiles.isNotEmpty) {
    largeFiles.sort((a, b) => b.lines.compareTo(a.lines));

    for (final file in largeFiles) {
      // ignore: avoid_print
      print('${file.path}: ${file.lines} lines');
    }
  }
}

Future<int> _countLines(File file) async {
  try {
    final lines = await file.readAsLines();
    return lines.length;
  } catch (e) {
    return 0;
  }
}

class FileInfo {
  final String path;
  final int lines;

  FileInfo(this.path, this.lines);
}
