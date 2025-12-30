import 'package:flutter/material.dart';

class AdminErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isRtl;

  const AdminErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _parseError(message);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            if (errorInfo.code != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  errorInfo.code!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              errorInfo.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorInfo.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorInfo _parseError(String message) {
    String? code;
    String title;
    String description;

    // Try to extract PostgreSQL error code
    final codeMatch = RegExp(r'code:\s*(\d+)').firstMatch(message);
    if (codeMatch != null) {
      code = codeMatch.group(1);
    }

    // Map common error codes to user-friendly messages
    if (code != null) {
      switch (code) {
        case '42703':
          title = isRtl ? 'خطأ في الاستعلام' : 'Query Error';
          description = isRtl
              ? 'عمود غير موجود في قاعدة البيانات'
              : 'Column does not exist in database';
          break;
        case '42883':
          title = isRtl ? 'خطأ في الاستعلام' : 'Query Error';
          description = isRtl
              ? 'نوع البيانات غير متوافق مع العملية المطلوبة'
              : 'Data type is incompatible with the requested operation';
          break;
        case '42501':
          title = isRtl ? 'غير مصرح' : 'Unauthorized';
          description = isRtl
              ? 'ليس لديك صلاحية للوصول لهذه البيانات'
              : 'You don\'t have permission to access this data';
          break;
        case '23505':
          title = isRtl ? 'بيانات مكررة' : 'Duplicate Data';
          description =
              isRtl ? 'هذه البيانات موجودة بالفعل' : 'This data already exists';
          break;
        case '23503':
          title = isRtl ? 'خطأ في العلاقات' : 'Reference Error';
          description = isRtl
              ? 'البيانات المرتبطة غير موجودة'
              : 'Referenced data does not exist';
          break;
        case '22P02':
          title = isRtl ? 'صيغة غير صحيحة' : 'Invalid Format';
          description = isRtl
              ? 'صيغة البيانات المدخلة غير صحيحة'
              : 'The input data format is invalid';
          break;
        case '28000':
        case '28P01':
          title = isRtl ? 'خطأ في المصادقة' : 'Authentication Error';
          description =
              isRtl ? 'فشل في التحقق من الهوية' : 'Failed to authenticate';
          break;
        case '57014':
          title = isRtl ? 'انتهت المهلة' : 'Timeout';
          description =
              isRtl ? 'استغرق الطلب وقتاً طويلاً' : 'The request took too long';
          break;
        default:
          title = isRtl ? 'حدث خطأ' : 'An Error Occurred';
          description = _getCleanDescription(message);
      }
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('socket')) {
      code = 'NET';
      title = isRtl ? 'خطأ في الاتصال' : 'Connection Error';
      description =
          isRtl ? 'تحقق من اتصالك بالإنترنت' : 'Check your internet connection';
    } else if (message.toLowerCase().contains('timeout')) {
      code = 'TIMEOUT';
      title = isRtl ? 'انتهت المهلة' : 'Timeout';
      description = isRtl
          ? 'استغرق الطلب وقتاً طويلاً، حاول مرة أخرى'
          : 'Request took too long, please try again';
    } else {
      title = isRtl ? 'حدث خطأ' : 'An Error Occurred';
      description = _getCleanDescription(message);
    }

    return _ErrorInfo(code: code, title: title, description: description);
  }

  String _getCleanDescription(String message) {
    var clean = message;

    // Remove "Failed to get X: " prefix
    clean = clean.replaceAll(RegExp(r'^Failed to \w+ \w+:\s*'), '');

    // Remove PostgrestException wrapper
    clean = clean.replaceAll('PostgrestException(message: ', '');
    clean = clean.replaceAll(')', '');

    // Extract just the message part
    final messageMatch = RegExp(r'message:\s*([^,]+)').firstMatch(clean);
    if (messageMatch != null) {
      clean = messageMatch.group(1) ?? clean;
    }

    // Truncate if too long
    if (clean.length > 100) {
      clean = '${clean.substring(0, 100)}...';
    }

    return clean.trim();
  }
}

class _ErrorInfo {
  final String? code;
  final String title;
  final String description;

  _ErrorInfo({
    this.code,
    required this.title,
    required this.description,
  });
}
