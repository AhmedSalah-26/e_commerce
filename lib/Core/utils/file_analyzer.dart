import 'dart:io';
import 'package:path/path.dart' as path;

enum FileType {
  presentation,
  data,
  domain,
  core,
  other,
}

class FileMetrics {
  final String filePath;
  final String relativePath;
  final int lineCount;
  final int sizeInBytes;
  final double sizeInKB;
  final int complexityScore;
  final FileType type;
  final int priority;
  final List<String> issues;
  final List<String> recommendations;

  FileMetrics({
    required this.filePath,
    required this.relativePath,
    required this.lineCount,
    required this.sizeInBytes,
    required this.sizeInKB,
    required this.complexityScore,
    required this.type,
    required this.priority,
    required this.issues,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'relativePath': relativePath,
        'lineCount': lineCount,
        'sizeInBytes': sizeInBytes,
        'sizeInKB': sizeInKB,
        'complexityScore': complexityScore,
        'type': type.name,
        'priority': priority,
        'issues': issues,
        'recommendations': recommendations,
      };
}

class FileAnalyzer {
  static const int lineLimitThreshold = 300;
  static const int sizeThresholdKB = 15;

  Future<List<FileMetrics>> analyzeCodebase(String rootPath) async {
    final List<FileMetrics> allMetrics = [];
    final libDir = Directory(path.join(rootPath, 'lib'));

    if (!await libDir.exists()) {
      throw Exception('lib directory not found at $rootPath');
    }

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        try {
          final metrics = await analyzeFile(entity, rootPath);
          allMetrics.add(metrics);
        } catch (e) {
          print('Error analyzing ${entity.path}: $e');
        }
      }
    }

    return allMetrics;
  }

  Future<FileMetrics> analyzeFile(File file, String rootPath) async {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final lineCount = lines.length;
    final sizeInBytes = await file.length();
    final sizeInKB = sizeInBytes / 1024;
    final relativePath = path.relative(file.path, from: rootPath);

    final fileType = _categorizeFile(relativePath);
    final complexityScore = _calculateComplexity(content);
    final priority = _calculatePriority(lineCount, sizeInKB, complexityScore);
    final issues = _identifyIssues(lineCount, sizeInKB, complexityScore);
    final recommendations = _generateRecommendations(issues, fileType);

    return FileMetrics(
      filePath: file.path,
      relativePath: relativePath,
      lineCount: lineCount,
      sizeInBytes: sizeInBytes,
      sizeInKB: sizeInKB,
      complexityScore: complexityScore,
      type: fileType,
      priority: priority,
      issues: issues,
      recommendations: recommendations,
    );
  }

  FileType _categorizeFile(String relativePath) {
    if (relativePath.contains('/presentation/')) {
      return FileType.presentation;
    } else if (relativePath.contains('/data/')) {
      return FileType.data;
    } else if (relativePath.contains('/domain/')) {
      return FileType.domain;
    } else if (relativePath.contains('/core/')) {
      return FileType.core;
    }
    return FileType.other;
  }

  int _calculateComplexity(String content) {
    int score = 0;

    // Count control flow statements
    score += 'if '.allMatches(content).length * 1;
    score += 'else'.allMatches(content).length * 1;
    score += 'for '.allMatches(content).length * 2;
    score += 'while '.allMatches(content).length * 2;
    score += 'switch '.allMatches(content).length * 2;
    score += 'case '.allMatches(content).length * 1;

    // Count nested structures
    score += 'class '.allMatches(content).length * 3;
    score += 'Future'.allMatches(content).length * 2;
    score += 'async'.allMatches(content).length * 2;
    score += 'await'.allMatches(content).length * 1;

    // Count widget complexity
    score += 'Widget'.allMatches(content).length * 2;
    score += 'State<'.allMatches(content).length * 3;
    score += 'StatefulWidget'.allMatches(content).length * 4;

    return score;
  }

  int _calculatePriority(int lineCount, double sizeInKB, int complexityScore) {
    int priority = 0;

    // Line count priority
    if (lineCount > 500) {
      priority += 5;
    } else if (lineCount > 400) {
      priority += 4;
    } else if (lineCount > 300) {
      priority += 3;
    }

    // Size priority
    if (sizeInKB > 30) {
      priority += 3;
    } else if (sizeInKB > 20) {
      priority += 2;
    } else if (sizeInKB > 15) {
      priority += 1;
    }

    // Complexity priority
    if (complexityScore > 200) {
      priority += 3;
    } else if (complexityScore > 150) {
      priority += 2;
    } else if (complexityScore > 100) {
      priority += 1;
    }

    return priority;
  }

  List<String> _identifyIssues(
      int lineCount, double sizeInKB, int complexityScore) {
    final List<String> issues = [];

    if (lineCount > lineLimitThreshold) {
      issues.add('File exceeds $lineLimitThreshold lines ($lineCount lines)');
    }

    if (sizeInKB > sizeThresholdKB) {
      issues.add(
          'File exceeds ${sizeThresholdKB}KB (${sizeInKB.toStringAsFixed(2)}KB)');
    }

    if (complexityScore > 150) {
      issues.add('High complexity score ($complexityScore)');
    }

    return issues;
  }

  List<String> _generateRecommendations(List<String> issues, FileType type) {
    final List<String> recommendations = [];

    if (issues.isEmpty) {
      return recommendations;
    }

    switch (type) {
      case FileType.presentation:
        recommendations.add('Extract reusable widgets into separate files');
        recommendations.add('Implement const constructors for static widgets');
        recommendations.add('Move business logic to Cubit/Service classes');
        break;
      case FileType.data:
        recommendations.add('Split repository by feature or responsibility');
        recommendations.add('Implement caching with size limits');
        recommendations.add('Add pagination for large datasets');
        break;
      case FileType.domain:
        recommendations.add('Split use cases into separate files');
        recommendations.add('Ensure single responsibility principle');
        break;
      case FileType.core:
        recommendations.add('Split utility classes by functionality');
        recommendations.add('Create separate files for constants');
        break;
      case FileType.other:
        recommendations.add('Review file structure and organization');
        break;
    }

    return recommendations;
  }
}
