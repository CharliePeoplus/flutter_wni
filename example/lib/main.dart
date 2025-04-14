import 'package:flutter/material.dart';
import 'package:flutter_wni/flutter_wni.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱 설정 초기화
  await WNInterface.init();

  runApp(const App());
}
