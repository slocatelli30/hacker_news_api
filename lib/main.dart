import 'package:flutter/material.dart';
import 'package:hacker_news_api/pages/home_page.dart';

/// main
void main() {
  /// runApp
  runApp(App());
}

/// classe App
class App extends StatelessWidget {
  /// TO DO - DA CHIEDERE A COSA SERVE
  const App({super.key});

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      /// home con istanza di HomePage
      home: HomePage(),

      /// rimuovere banner di debug
      debugShowCheckedModeBanner: false,
    );
  }
}
