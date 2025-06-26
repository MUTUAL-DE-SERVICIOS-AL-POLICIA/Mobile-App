import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webscreen extends StatefulWidget {
  final String initialUrl;

  const Webscreen({super.key, required this.initialUrl});

  @override
  State<Webscreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<Webscreen> {
  late final WebViewController _controller;
  
  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final url = request.url;
          if (url.startsWith('com.muserpol.pvt:/oauth2redirect')) {
            final uri = Uri.parse(url);
            final code = uri.queryParameters['code'];
            final error = uri.queryParameters['error'];

            if (error != null) {
              print('Error: $error');
              Navigator.pop(context); 
              return NavigationDecision.prevent;
            }

            if (code != null) {
              print('Authorization code recibido: $code');
              Navigator.pop(
                  context, code); 
              return NavigationDecision.prevent;
            }
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudadanía Digital'),
        backgroundColor: const Color(0xff419388),
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
