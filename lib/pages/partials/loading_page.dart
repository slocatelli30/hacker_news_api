import 'package:flutter/material.dart';

/// classe LoadingPage
/// per il caricamento/loading delle news
class LoadingPage extends StatelessWidget {
  /// costruttore
  const LoadingPage({super.key});

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return Container(
      // colore di sfondo (Container)
      color: Colors.white,
      // allineamento del Container
      alignment: Alignment.center,
      // child di Container
      child: CircularProgressIndicator(
        // colore della CircularProgressIndicator
        color: Colors.black,
      ),
    );
  }
}
