import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/payment_result.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResult) onPaymentComplete;

  const PaymentPage({
    super.key,
    required this.paymentUrl,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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

            // Check for success callback
            if (url.contains('success=true') ||
                url.contains('txn_response_code=APPROVED')) {
              _handlePaymentSuccess(url);
              return NavigationDecision.prevent;
            }

            // Check for failure callback
            if (url.contains('success=false') ||
                url.contains('txn_response_code=DECLINED')) {
              _handlePaymentFailure(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentSuccess(String url) {
    final uri = Uri.parse(url);
    final transactionId = uri.queryParameters['id'] ??
        uri.queryParameters['transaction_id'] ??
        '';

    widget.onPaymentComplete(PaymentResult.success(
      transactionId: transactionId,
      message: 'Payment successful',
    ));

    if (mounted) context.pop();
  }

  void _handlePaymentFailure(String url) {
    final uri = Uri.parse(url);
    final message = uri.queryParameters['data.message'] ?? 'Payment failed';

    widget.onPaymentComplete(PaymentResult.failure(message: message));

    if (mounted) context.pop();
  }

  void _handleCancel() {
    widget.onPaymentComplete(PaymentResult.cancelled());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
          onPressed: _handleCancel,
        ),
        title: Text(
          isRtl ? 'الدفع بالبطاقة' : 'Card Payment',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRtl
                          ? 'جاري تحميل صفحة الدفع...'
                          : 'Loading payment page...',
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
