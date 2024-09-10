import 'package:bamtol_market_02/main.dart';
import 'package:bamtol_market_02/src/init/page/init_start_page.dart';
import 'package:bamtol_market_02/src/splash/page/splash_page.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 처음인지 여부
  late bool isInitStarted;

  @override
  void initState() {
    super.initState();
    // 처음 시작할 때 값이 없으면,
    isInitStarted = prefs.getBool('isInitStarted') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return isInitStarted
        ? InitStartPage(
            onStart: () {
              setState(() {
                isInitStarted = false;
              });
              prefs.setBool('isInitStarted', isInitStarted);
            },
          )
        : const SplashPage();
  }
}
