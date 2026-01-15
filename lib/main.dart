import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator için eklendi
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher paketini ekleyin

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web View',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            // Eğer link mailto: ile başlıyorsa
            if (request.url.startsWith('mailto:')) {
              final Uri emailLaunchUri = Uri.parse(request.url);

              // E-posta uygulamasını açmaya çalış
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
              return NavigationDecision
                  .prevent; // WebView'in bu linki yüklemesini engelle
            }

            // Diğer durumlar (tel:, sms: vb.) için de benzeri yapılabilir
            if (request.url.startsWith('tel:')) {
              final Uri telLaunchUri = Uri.parse(request.url);
              if (await canLaunchUrl(telLaunchUri)) {
                await launchUrl(telLaunchUri);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision
                .navigate; // Normal http/https linklerine devam et
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://onlinepdks.com.tr/'));
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold'u PopScope ile sarıyoruz
    return PopScope(
      canPop:
          false, // Geri tuşunun otomatik olarak uygulamayı kapatmasını engelle
      onPopInvoked: (bool didPop) async {
        // Eğer pop işlemi zaten gerçekleştiyse (canPop:true olsaydı olabilirdi), bir şey yapma.
        if (didPop) {
          return;
        }

        // WebView'in geri gidecek bir sayfası olup olmadığını kontrol et.
        final bool canGoBack = await _controller.canGoBack();

        if (canGoBack) {
          // Eğer geri gidebiliyorsa, webview içinde geri git.
          _controller.goBack();
        } else {
          // Eğer webview'in geçmişi yoksa, uygulamayı kapat.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
