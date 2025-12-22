import 'dart:io';
import 'package:e_commerce/core/utils/file_analyzer.dart';
import 'package:e_commerce/core/utils/report_generator.dart';

void main() async {
  print('Starting codebase analysis...');

  final analyzer = FileAnalyzer();
  final reportGenerator = ReportGenerator();

  try {
    // Get current directory
    final currentDir = Directory.current.path;
    print('Analyzing directory: $currentDir');

    // Analyze codebase
    final metrics = await analyzer.analyzeCodebase(currentDir);
    print('Analyzed ${metrics.length} files');

    // Generate reports
    final analysisReport = reportGenerator.generateAnalysisReport(metrics);
    final optimizationPlan = reportGenerator.generateOptimizationPlan(metrics);

    // Save reports
    final reportsDir = Directory('reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create();
    }

    final analysisFile = File('reports/codebase_analysis.md');
    await analysisFile.writeAsString(analysisReport);
    print('Analysis report saved to: ${analysisFile.path}');

    final planFile = File('reports/optimization_plan.md');
    await planFile.writeAsString(optimizationPlan);
    print('Optimization plan saved to: ${planFile.path}');

    print('\nAnalysis complete!');
  } catch (e, stackTrace) {
    print('Error during analysis: $e');
    print(stackTrace);
    exit(1);
  }
}
