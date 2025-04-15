import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:reflectable/reflectable.dart';
import 'package:webview_flutter/webview_flutter.dart';

// class WNInterfaceReflectable extends Reflectable {
//   const WNInterfaceReflectable() : super(invokingCapability);
// }

// const wninterface = WNInterfaceReflectable();

class WNInterfacePayload {
  final String command;
  final Map<String, dynamic> data;

  WNInterfacePayload({required this.command, required this.data});

  factory WNInterfacePayload.fromMessage(JavaScriptMessage message) {
    var map = jsonDecode(message.message);

    if (map.containsKey("version") && map.containsKey("payload")) {
      // ignore: unused_local_variable
      String version = map['version'] as String;
      Map<String, dynamic> payload = Map<String, dynamic>.from(map["payload"]);

      if (payload.containsKey("command") && payload.containsKey("data")) {
        return WNInterfacePayload(
            command: payload["command"] as String,
            data: Map<String, dynamic>.from(payload["data"]));
      }
    }

    return WNInterfacePayload(command: "", data: jsonDecode("{}"));
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'command': command, 'data': data};
}

class WNInterface {
  
  late final Map<String, Function> _methods;
  late final WebViewController _controller;
  late final BuildContext _context;

  WebViewController get controller => _controller;
  BuildContext get context => _context;

  WNInterface(
      {required WebViewController controller, required BuildContext context}) {

    _controller = controller;
    _context = context;

    setupAndroidSafeArea();
  }

  // JavascriptChannel 등록
  Future<void> initialize() async {
    await initJavaScriptChannel((payload) {
      execute(payload);
    });
  }

  void registerMethods( Map<String, Function> methods ) {
    _methods = methods;
  }

  void setupAndroidSafeArea() {
    final EdgeInsets safeArea = MediaQuery.of(_context).padding;

    _controller.runJavaScript(
        "document.documentElement.style.setProperty('--android-safe-area-inset-top', '${safeArea.top.toString()}px');");
    _controller.runJavaScript(
        "document.documentElement.style.setProperty('--android-safe-area-inset-left', '${safeArea.left.toString()}px');");
    _controller.runJavaScript(
        "document.documentElement.style.setProperty('--android-safe-area-inset-right', '${safeArea.right.toString()}px');");
    _controller.runJavaScript(
        "document.documentElement.style.setProperty('--android-safe-area-inset-bottom', '${safeArea.bottom.toString()}px');");
  }

  void call(String scriptFunction, String jsonString) {
    final String script =
        scriptFunction + "('" + jsonString.replaceAll("'", "\\'") + "')";
    //print("script : ${script}");
    _controller.runJavaScript(script);
  }
  
  void execute(WNInterfacePayload payload) {
    Function? handler = _methods[payload.command];
    if (handler != null) {
      Function.apply(handler, [payload.data]);
    }
    else {
      // ignore: avoid_print
      print("Unknown Command : ${payload.command}");
    }
  }

  static String getInterfaceName() {
    if (Platform.isAndroid) {
      return "NativeAndroid";
    } else if (Platform.isIOS) {
      return "NativeiOS";
    }
    return "VirtualInterface";
  }

  Future<void> initJavaScriptChannel(Function(WNInterfacePayload payload) handler) async {
    await _controller.addJavaScriptChannel(
      getInterfaceName(),
      onMessageReceived: (JavaScriptMessage message) {
        handler(WNInterfacePayload.fromMessage(message));
      },
    );
  }

  // Webview 4.x 버전 아후에는 JavascriptChannel을 직접 사용할 수 없음 
  // 
  // static JavascriptChannel getJavascriptChannel(Function (WNInterfacePayload payload) handler) {
  //   return JavascriptChannel(
  //       name: getInterfaceName(),
  //       onMessageReceived: (JavaScriptMessage message) {
  //         handler(WNInterfacePayload.fromMessage(message));
  //       });
  // }

  static bool get isEmulator {
    if (Platform.isIOS) {
      return FlutterWNInterface.getProperty("isEmulator");
    }
    return false;
  }

  static String get interfaceVersion => FlutterWNInterface.getProperty("interfaceVersion");
  static String get appId => FlutterWNInterface.getProperty("appId");
  static String get appName => FlutterWNInterface.getProperty("appName");
  static String get appVersion => FlutterWNInterface.getProperty("appVersion");
  static String get buildVersion => FlutterWNInterface.getProperty("buildVersion");
  static String get systemName => FlutterWNInterface.getProperty("systemName");
  static String get systemVersion => FlutterWNInterface.getProperty("systemVersion");
  static String get osType => FlutterWNInterface.getProperty("osType");
  static String get osVersion => FlutterWNInterface.getProperty("osVersion");
  static String get deviceId => FlutterWNInterface.getProperty("deviceId");
  static String get deviceLocale => FlutterWNInterface.getProperty("deviceLocale");
  static String get deviceModel => FlutterWNInterface.getProperty("deviceModel");
  static String get deviceName => FlutterWNInterface.getProperty("deviceName");
  static String get deviceType => FlutterWNInterface.getProperty("deviceType");
  static String get deviceBrand => FlutterWNInterface.getProperty("deviceBrand");
  
  static String get userAgent {
    try {
      return (FlutterWNInterface.getProperty("webViewUserAgent") ?? "Unknown") + " WNInterface/v1";
    } on PlatformException {
      return "WNInterface/v1";
    }
  }

  static Future init() async {
    await FlutterWNInterface.init();
  }
}

class FlutterWNInterface {
  static const MethodChannel _channel = MethodChannel('flutter_wni_plugin');
  static Map<String, dynamic>? _properties;

  /// Initialize the module.
  ///
  /// This is usually called before the module can be used.
  ///
  /// Set [force] to true if you want to refetch the user agent properties from
  /// the native platform.
  static Future init({force: false}) async {
    if (_properties == null || force) {
      _properties = Map.unmodifiable(await (_channel.invokeMethod('getProperties')));
    }
  }

  /// Release all the user agent properties statically cached.
  /// You can call this function when you no longer need to access the properties.
  static void release() {
    _properties = null;
  }

  /// Returns the device's user agent.
  static String? get userAgent {
    return _properties!['userAgent'];
  }

  /// Returns the device's webview user agent.
  static String? get webViewUserAgent {
    return _properties!['webViewUserAgent'];
  }

  /// Fetch a [property] that can be used to build your own user agent string.
  static dynamic getProperty(String property) {
    return _properties![property];
  }

  /// Fetch a [property] asynchronously that can be used to build your own user agent string.
  static dynamic getPropertyAsync(String property) async {
    await init();
    return _properties![property];
  }

  /// Return a map of properties that can be used to generate the user agent string.
  static Map<String, dynamic>? get properties {
    return _properties;
  }
}
