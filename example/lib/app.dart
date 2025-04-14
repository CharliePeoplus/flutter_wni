import 'package:flutter/material.dart';
import 'pages/web_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.white,
              shadowColor: Colors.transparent,
              centerTitle: false),
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color.fromRGBO(40, 150, 255, 1),
        ),
        home: const SafeArea(
          child: WebPage(
            url: "https://app.dev.lugstay.com",
          ),
        ));
  }
}
