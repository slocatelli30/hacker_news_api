import 'package:flutter/material.dart';

/// TO DO
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  /// TO DO
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
