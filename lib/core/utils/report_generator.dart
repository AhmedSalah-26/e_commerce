import 'file_analyzer.dart';

class ReportGenerator {
  String generateAnalysisReport(List<FileMetrics> metrics) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# Codebase Analysis Report');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln();

    // Summary Statistics
    buffer.writeln('## Summary Statistics');
    buffer.writeln();
    _writeSummaryStats(buffer, metrics);
    buffer.writeln();

    // Files by Type
    buffer.writeln('## Files by Type');
    buffer.writeln();
    _writeFilesByType(buffer, metrics);
    buffer.writeln();

    // Large Files (Priority)
    buffer.writeln('## Large Files (Prioritized)');
    buffer.writeln();
    _writeLargeFiles(buffer, metrics);
    buffer.writeln();

    // Detailed Analysis
    buffer.writeln('## Detailed Analysis');
    buffer.writeln();
    _writeDetailedAnalysis(buffer, metrics);

    return buffer.toString();
  }

  void _writeSummaryStats(StringBuffer buffer, List<FileMetrics> metrics) {
    final totalFiles = metrics.length;
    final largeFiles = metrics
        .where((m) =>
            m.lineCount > FileAnalyzer.lineLimitThreshold ||
            m.sizeInKB > FileAnalyzer.sizeThresholdKB)
        .length;

    final avgLineCount = metrics.isEmpty
        ? 0
        : metrics.map((m) => m.lineCount).reduce((a, b) => a + b) /
            metrics.length;

    final avgSize = metrics.isEmpty
        ? 0
        : metrics.map((m) => m.sizeInKB).reduce((a, b) => a + b) /
            metrics.length;

    final totalLines = metrics.map((m) => m.lineCount).fold(0, (a, b) => a + b);

    buffer.writeln('- **Total Files**: $totalFiles');
    buffer.writeln(
        '- **Large Files**: $largeFiles (${(largeFiles / totalFiles * 100).toStringAsFixed(1)}%)');
    buffer.writeln('- **Average File Size**: ${avgSize.toStringAsFixed(2)} KB');
    buffer.writeln(
        '- **Average Lines per File**: ${avgLineCount.toStringAsFixed(0)}');
    buffer.writeln('- **Total Lines of Code**: $totalLines');
  }

  void _writeFilesByType(StringBuffer buffer, List<FileMetrics> metrics) {
    final byType = <FileType, List<FileMetrics>>{};

    for (final metric in metrics) {
      byType.putIfAbsent(metric.type, () => []).add(metric);
    }

    buffer.writeln('| Type | Count | Avg Lines | Avg Size (KB) |');
    buffer.writeln('|------|-------|-----------|---------------|');

    for (final type in FileType.values) {
      final files = byType[type] ?? [];
      if (files.isEmpty) continue;

      final avgLines =
          files.map((f) => f.lineCount).reduce((a, b) => a + b) / files.length;
      final avgSize =
          files.map((f) => f.sizeInKB).reduce((a, b) => a + b) / files.length;

      buffer.writeln(
          '| ${type.name} | ${files.length} | ${avgLines.toStringAsFixed(0)} | ${avgSize.toStringAsFixed(2)} |');
    }
  }

  void _writeLargeFiles(StringBuffer buffer, List<FileMetrics> metrics) {
    final largeFiles = metrics.where((m) => m.issues.isNotEmpty).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    if (largeFiles.isEmpty) {
      buffer.writeln('No files exceed the thresholds.');
      return;
    }

    buffer.writeln('| Priority | File | Lines | Size (KB) | Type | Issues |');
    buffer.writeln('|----------|------|-------|-----------|------|--------|');

    for (final file in largeFiles.take(20)) {
      final issuesStr = file.issues.join('; ');
      buffer.writeln(
          '| ${file.priority} | ${file.relativePath} | ${file.lineCount} | ${file.sizeInKB.toStringAsFixed(2)} | ${file.type.name} | $issuesStr |');
    }

    if (largeFiles.length > 20) {
      buffer.writeln();
      buffer.writeln(
          '*Showing top 20 files. Total large files: ${largeFiles.length}*');
    }
  }

  void _writeDetailedAnalysis(StringBuffer buffer, List<FileMetrics> metrics) {
    final largeFiles = metrics.where((m) => m.issues.isNotEmpty).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final file in largeFiles.take(10)) {
      buffer.writeln('### ${file.relativePath}');
      buffer.writeln();
      buffer.writeln('**Metrics:**');
      buffer.writeln('- Lines: ${file.lineCount}');
      buffer.writeln('- Size: ${file.sizeInKB.toStringAsFixed(2)} KB');
      buffer.writeln('- Complexity: ${file.complexityScore}');
      buffer.writeln('- Type: ${file.type.name}');
      buffer.writeln('- Priority: ${file.priority}');
      buffer.writeln();

      if (file.issues.isNotEmpty) {
        buffer.writeln('**Issues:**');
        for (final issue in file.issues) {
          buffer.writeln('- $issue');
        }
        buffer.writeln();
      }

      if (file.recommendations.isNotEmpty) {
        buffer.writeln('**Recommendations:**');
        for (final rec in file.recommendations) {
          buffer.writeln('- $rec');
        }
        buffer.writeln();
      }
    }
  }

  String generateOptimizationPlan(List<FileMetrics> metrics) {
    final buffer = StringBuffer();

    buffer.writeln('# Optimization Plan');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln();

    final prioritizedFiles = metrics.where((m) => m.issues.isNotEmpty).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    buffer.writeln(
        '## High Priority Files (${prioritizedFiles.where((f) => f.priority >= 5).length})');
    buffer.writeln();

    for (final file in prioritizedFiles.where((f) => f.priority >= 5)) {
      buffer.writeln('### ${file.relativePath}');
      buffer.writeln(
          '**Priority:** ${file.priority} | **Lines:** ${file.lineCount} | **Size:** ${file.sizeInKB.toStringAsFixed(2)} KB');
      buffer.writeln();
      buffer.writeln('**Recommended Actions:**');
      for (final rec in file.recommendations) {
        buffer.writeln('- [ ] $rec');
      }
      buffer.writeln();
    }

    buffer.writeln(
        '## Medium Priority Files (${prioritizedFiles.where((f) => f.priority >= 3 && f.priority < 5).length})');
    buffer.writeln();

    for (final file
        in prioritizedFiles.where((f) => f.priority >= 3 && f.priority < 5)) {
      buffer.writeln(
          '- ${file.relativePath} (Priority: ${file.priority}, Lines: ${file.lineCount})');
    }

    return buffer.toString();
  }
}
