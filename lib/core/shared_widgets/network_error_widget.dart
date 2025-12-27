import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Widget to display when there's a network error
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'error_network'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'check_connection'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show full screen network error dialog
  /// Dialog stays until operation succeeds
  static void showFullScreen(BuildContext context,
      {required Future<bool> Function() onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog.fullscreen(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: _NetworkErrorDialogContent(
            onRetry: onRetry,
            dialogContext: ctx,
          ),
        ),
      ),
    );
  }
}

class _NetworkErrorDialogContent extends StatefulWidget {
  final Future<bool> Function() onRetry;
  final BuildContext dialogContext;

  const _NetworkErrorDialogContent({
    required this.onRetry,
    required this.dialogContext,
  });

  @override
  State<_NetworkErrorDialogContent> createState() =>
      _NetworkErrorDialogContentState();
}

class _NetworkErrorDialogContentState
    extends State<_NetworkErrorDialogContent> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);

    final success = await widget.onRetry();

    if (mounted) {
      setState(() => _isRetrying = false);
      if (success) {
        Navigator.of(widget.dialogContext).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'error_network'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'check_connection'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isRetrying ? null : _handleRetry,
              icon: _isRetrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
