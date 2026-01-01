import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/payment_result.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResult) onPaymentComplete;
  final VoidCallback onCancel;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.onPaymentComplete,
    required this.onCancel,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains('success=true') ||
                url.contains('txn_response_code=APPROVED')) {
              _handleSuccess(url);
              return NavigationDecision.prevent;
            }

            if (url.contains('success=false') ||
                url.contains('txn_response_code=DECLINED')) {
              _handleFailure(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleSuccess(String url) {
    final uri = Uri.parse(url);
    final transactionId = uri.queryParameters['id'] ??
        uri.queryParameters['transaction_id'] ??
        '';

    widget.onPaymentComplete(PaymentResult.success(
      transactionId: transactionId,
      message: 'Payment successful',
    ));
  }

  void _handleFailure(String url) {
    final uri = Uri.parse(url);
    final message = uri.queryParameters['data.message'] ?? 'Payment failed';

    widget.onPaymentComplete(PaymentResult.failure(message: message));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: widget.onCancel,
              ),
              Expanded(
                child: Text(
                  isRtl ? 'الدفع بالبطاقة' : 'Card Payment',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // WebView
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: WebViewWidget(controller: _controller),
              ),
              if (_isLoading)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isRtl ? 'جاري تحميل صفحة الدفع...' : 'Loading...',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
