import 'package:flutter/material.dart';

/// classe ErrorInfoPage
/// componente personalizzato per mostrare
/// informazioni di errore durante il caricamento
/// dei dati in "home_page.dart".
/// Loading, Error, No data (null), Empty list, Success (tutto ok)
class ErrorInfoPage extends StatelessWidget {
  /// messaggio di testo per informazioni
  final String infoText;

  /// scritta all'interno del pulsante
  final String buttonText;

  /// "VoidCallback?" è una funzione che non prende parametri
  /// e non restituisce nulla, ma può essere null (opzionale).
  /// La variabile "onRefresh" è una callback,
  /// cioè una funzione che verrà eseguita
  /// quando l'utente preme il pulsante di refresh sull'AppBar
  final VoidCallback? onRefresh;

  /// costruttore
  const ErrorInfoPage({
    super.key,
    // info
    required this.infoText,
    // testo pulsante
    required this.buttonText,
    // refresh/aggiornamento dei dati
    required this.onRefresh,
  });

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // informazioni messaggio
          Text(
            infoText,
            style: TextStyle(
              // colore info messaggio
              color: Colors.white,
              // font info messaggio
              fontStyle: FontStyle.italic,
            ),
          ),
          // spaziatura verticale
          const SizedBox(height: 12),

          // pulsante per il refresh
          IconButton(
            /// onPressed per il refresh.
            /// Callback passata dall'esterno.
            /// La AppBar rimane "stupida" non conoscendo
            /// cosa sta sotto a "downloadStoryData".
            /// Sa solo: "quando clicco refresh, chiamo onRefresh"
            onPressed: onRefresh,
            // icona di refresh
            icon: Icon(Icons.refresh_rounded),
            // stile di IB
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
