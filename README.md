# WNInterface for Flutter

[![pub package](https://img.shields.io/pub/v/flutter_wni.svg)](https://pub.dev/packages/flutter_wni)

Flutter WebView 에 WNInterface 기능을 추가해줍니다.

```dart
class WebPage extends StatefulWidget {
  final String url;

  const WebPage({Key? key, required this.url}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late WNInterface _interface;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => goBack(context),
      child: Stack(
        children: [
          WebView(
            debuggingEnabled: true,
            initialUrl: widget.url,
            userAgent: WNInterface.getUserAgent(),
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: {
              WNInterface.getJavascriptChannel((WNInterfacePayload payload) async {
                // ignore: avoid_print
                print("payload.command: " + payload.command);

                switch (payload.command) {

                  // WNInterface Method 연경

                  default:
                    // ignore: avoid_print
                    print("Unknown Command : ${payload.command}");
                    break;
                }
              })
            },
            onWebViewCreated: (WebViewController controller) async {
              _interface = WNInterface(controller: controller, context: context);
              _interface.controller.clearCache();
            },
          ),
        ],
      ),
    );
  }

  Future<bool> goBack(BuildContext context) async {
    if (await _interface.controller.canGoBack()) {
      _interface.controller.goBack();
      return Future.value(false);
    }

    return Future.value(true);
  }

  // WNInterface Method 구현 
}
```