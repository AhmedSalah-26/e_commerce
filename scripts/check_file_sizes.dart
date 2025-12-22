import 'dart:io';

/// Script to check file sizes and identify files that need splitting
/// Usage: dart scripts/check_file_sizes.dart
void main() async {
  const maxLines = 300;
  final featuresDir = Directory('lib/features');

  if (!await featuresDir.exists()) {
    print('❌ lib/features directory not found');
    return;
  }

  print('🔍 Checking file sizes in lib/features...\n');
  print('=' * 80);
  print('Files larger than $maxLines lines:\n');

  final largeFiles = <FileInfo>[];

  await for (final entity in featuresDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final lines = await _countLines(entity);
      if (lines > maxLines) {
        largeFiles.add(FileInfo(entity.path, lines));
      }
    }
  }

  if (largeFiles.isEmpty) {
    print('✅ All files are within the $maxLines lines limit!');
  } else {
    largeFiles.sort((a, b) => b.lines.compareTo(a.lines));

    for (var i = 0; i < largeFiles.length; i++) {
      final file = largeFiles[i];
      final relativePath =
          file.path.replaceAll('\\', '/').replaceFirst('lib/features/', '');
      final excess = file.lines - maxLines;
      final status = file.lines > 500
          ? '🔴'
          : file.lines > 400
              ? '🟠'
              : '🟡';

      print('${i + 1}. $status $relativePath');
      print('   Lines: ${file.lines} (+$excess over limit)');
      print('');
    }

    print('=' * 80);
    print('\n📊 Summary:');
    print('   Total files checked: ${await _countDartFiles(featuresDir)}');
    print('   Files over limit: ${largeFiles.length}');
    print('   Largest file: ${largeFiles.first.lines} lines');
    print(
        '   Average excess: ${_calculateAverageExcess(largeFiles, maxLines).toStringAsFixed(0)} lines');

    print('\n💡 Recommendation:');
    print('   Split these files into smaller widgets/components');
    print('   Target: <$maxLines lines per file for better maintainability');
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

Future<int> _countDartFiles(Directory dir) async {
  var count = 0;
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      count++;
    }
  }
  return count;
}

double _calculateAverageExcess(List<FileInfo> files, int maxLines) {
  if (files.isEmpty) return 0;
  final totalExcess =
      files.fold<int>(0, (sum, file) => sum + (file.lines - maxLines));
  return totalExcess / files.length;
}

class FileInfo {
  final String path;
  final int lines;

  FileInfo(this.path, this.lines);
}
