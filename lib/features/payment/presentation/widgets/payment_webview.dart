import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/payment_result.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResult) onPaymentComplete;
  final VoidCallback onCancel;
  final bool isWalletPayment;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.onPaymentComplete,
    required this.onCancel,
    this.isWalletPayment = false,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

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
            debugPrint('🔵 WebView Page Started: $url');
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (url) {
            debugPrint('🔵 WebView Page Finished: $url');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('❌ WebView Error: ${error.description}');
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;
            debugPrint('🔵 WebView Navigation: $url');

            // Check for success indicators
            if (url.contains('success=true') ||
                url.contains('txn_response_code=APPROVED') ||
                url.contains('pending=false&success=true')) {
              _handleSuccess(url);
              return NavigationDecision.prevent;
            }

            // Check for failure indicators
            if (url.contains('success=false') ||
                url.contains('txn_response_code=DECLINED') ||
                url.contains('pending=false&success=false')) {
              _handleFailure(url);
              return NavigationDecision.prevent;
            }

            // For wallet payments, allow navigation to wallet provider pages
            // These are external URLs that handle the actual payment
            if (widget.isWalletPayment) {
              // Allow all navigations for wallet - the wallet provider will redirect back
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    debugPrint('🔵 Loading payment URL: ${widget.paymentUrl}');
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

    // Dynamic title based on payment type
    final title = widget.isWalletPayment
        ? (isRtl ? 'الدفع بالمحفظة' : 'Wallet Payment')
        : (isRtl ? 'الدفع بالبطاقة' : 'Card Payment');

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
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
                    title,
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
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
                if (_errorMessage != null && !_isLoading)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRtl
                                ? 'فشل في تحميل صفحة الدفع'
                                : 'Failed to load payment page',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _isLoading = true;
                              });
                              _controller
                                  .loadRequest(Uri.parse(widget.paymentUrl));
                            },
                            child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
