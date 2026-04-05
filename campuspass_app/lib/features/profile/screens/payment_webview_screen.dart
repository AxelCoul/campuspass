import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  bool _isLoading = true;
  bool _closed = false;
  late final WebViewController _controller;

  void _close(bool result) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(result);
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            final mainFrameError = error.isForMainFrame ?? false;
            if (mainFrameError) {
              _close(false);
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;
            // Quand YengaPay termine, elle charge l’URL de return-url côté backend.
            // On ferme alors la WebView et on laisse le parent faire la vérification.
            if (url.contains('/api/subscription/yengapay/return')) {
              _close(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement YengaPay'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}

