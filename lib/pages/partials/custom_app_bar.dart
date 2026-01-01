import 'package:flutter/material.dart';

/// classe CustomAppBar
/// componente custom AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// "VoidCallback?" è una funzione che non prende parametri
  /// e non restituisce nulla, ma può essere null (opzionale).
  /// La variabile "onRefresh" è una callback,
  /// cioè una funzione che verrà eseguita
  /// quando l'utente preme il pulsante di refresh sull'AppBar
  final VoidCallback? onRefresh;

  /// costruttore + parametri
  const CustomAppBar({super.key, this.onRefresh});

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return AppBar(
      /// "foregroundColor" controlla il colore di tutti gli elementi
      /// foreground dell’AppBar
      foregroundColor: Colors.black,

      /// title di AppBar con Container
      title: Container(
        // padding
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "News!",
          // style di Text
          style: const TextStyle(
            // colore
            color: Colors.white,
            // dimensioni
            fontSize: 17,
            // grassetto
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// actions
      actions: [
        IconButton(
          // colori IB
          splashColor: Colors.green,

          /// onPressed per il refresh.
          /// Callback passata dall'esterno.
          /// La AppBar rimane "stupida" non conoscendo
          /// cosa sta sotto a "downloadStoryData".
          /// Sa solo: "quando clicco refresh, chiamo onRefresh"
          onPressed: onRefresh,
          // icona di refresh
          icon: Icon(Icons.refresh_rounded),
        ),
      ],

      /// Title al centro (AppBar)
      centerTitle: true,

      /// colore di sfondo (AppBar)
      backgroundColor: Colors.white,
    );
  }

  /// Questo getter è obbligatorio.
  /// Senza di esso, Flutter non accetta l'AppBar custom.
  /// "preferredSize" è una proprietà obbligatoria per qualsiasi widget
  /// che implementa PreferredSizeWidget, come la AppBar.
  /// Senza questa proprietà,
  /// Flutter non saprebbe come calcolare la dimensione del widget
  /// e genererebbe un errore.
  @override
  Size get preferredSize =>
      /// Si indica a Flutter che l'altezza della tua AppBar è 48.0
      /// (altezza standard di kToolbarHeight)
      const Size.fromHeight(kToolbarHeight);
}
