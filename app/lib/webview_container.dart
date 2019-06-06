import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  @override
  State<WebViewContainer> createState() {
    return WebViewState();
  }
}

class WebViewState extends State<WebViewContainer> {
  int _index = 0;

  void handleLoad(String value) {
    setState(() {
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context).settings.arguments;
    String title = args[0];
    String url = args[1];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: IndexedStack(index: _index, children: [
        Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: handleLoad,
        ),
      ]),
    );
  }
}
