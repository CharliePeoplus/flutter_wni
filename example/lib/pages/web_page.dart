// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_wni/flutter_wni.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebPage extends StatefulWidget {
  final String url;

  const WebPage({Key? key, required this.url}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late WNInterface _interface;

  void updateWidgetList(String invoiceNumber) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => goBack(context),
      child: Stack(
        children: [
          WebView(
            debuggingEnabled: true,
            initialUrl: widget.url,
            userAgent: WNInterface.userAgent,
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: {WNInterface.getJavascriptChannel(onExecute)},
            onWebViewCreated: (WebViewController controller) async {
              _interface =
                  WNInterface(controller: controller, context: context);
              _interface.controller.clearCache();
            },
          ),
        ],
      ),
    );
  }

  // LifeCycle Methods
  void onContentLoaded() async {
    onReady();
  }

  void onReady() async {
    _interface.call("WNInterface.responder.onInitPage", jsonEncode({"status": "SUCCESS"}));
  }

  void onAppear() async {}

  void onDisappear() async {}

  void onLink() async {}

  void onCustom(userInfo) async {
    _interface.call("WNInterface.responder.onRemoteNotification", jsonEncode(userInfo));
  }

  void onBackPressed() async {
    _interface.call("WNInterface.responder.onBackPage", jsonEncode({}));
  }

  void onRemoteNotification(userInfo) async {
    _interface.call("WNInterface.responder.onRemoteNotification", jsonEncode(userInfo));
  }

  Future<bool> goBack(BuildContext context) async {
    return Future.value(false);
  }

  void onExecute(WNInterfacePayload payload) {
    print("payload.command: " + payload.command);

    switch (payload.command) {
      case "wnGetSafeArea":
        wnGetSafeArea(payload.data);
        break;

      case "wnGetStorage":
        wnGetStorage(payload.data);
        break;

      case "wnSetStorage":
        wnSetStorage(payload.data);
        break;

      case "wnGetDeviceInfo":
        wnGetDeviceInfo(payload.data);
        break;


      default:
        print("Switch Default : ${payload.command}");
        break;
    }
  }

  // WNInterface Methods 

  void wnGetSafeArea(data) async {
    final String callback = data["callback"] as String;
    final EdgeInsets safeArea = MediaQuery.of(context).padding;
    final Map<String, dynamic> result = <String, dynamic>{};
    result["top"] = safeArea.top;
    result["left"] = safeArea.left;
    result["right"] = safeArea.right;
    result["bottom"] = safeArea.bottom;

    _interface.call(callback, jsonEncode(result));
  }

  void wnGetStorage(data) async {
    final String callback = data["callback"] as String;
    final String key = data["key"] as String;
    final prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(key);
    print("jsonEncode : ${{
      "status": "SUCCESS",
      "key": key,
      "value": value ?? ""
    }}");

    _interface.call(callback,
        jsonEncode({"status": "SUCCESS", "key": key, "value": value ?? ""}));
  }

  void wnSetStorage(data) async {
    final String callback = data["callback"] as String;
    final String key = data["key"] as String;
    final String value = data["value"] as String;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);

    _interface.call(callback,
        jsonEncode({"status": "SUCCESS", "key": key, "value": value}));
  }

  // WNInterface.execute("wnGetDeviceInfo", { callback: WNInterface.cb( function( data ) { console.log( data ); }) });
  void wnGetDeviceInfo(data) async {
    final String callback = data["callback"] as String;
    var info = {
      "interfaceVersion": WNInterface.interfaceVersion,
      "appId": WNInterface.appId,
      "appName": WNInterface.appName,
      "appVersion": WNInterface.appVersion,
      "buildVersion": WNInterface.buildVersion,
      "osType": WNInterface.osType,
      "osVersion": WNInterface.osVersion,
      "deviceId": WNInterface.deviceId,
      "deviceLocale": WNInterface.deviceLocale,
      "deviceModel": WNInterface.deviceModel,
      "deviceType": WNInterface.deviceType,
      "deviceBrand": WNInterface.deviceBrand,
      "pushToken": "",
    };

    _interface.call(callback, jsonEncode({
      "status": "SUCCESS",
      "info": info
    }));
  }
}
