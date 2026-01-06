import 'package:flutter/material.dart';

/// Enumerativi InfoType.
/// Servono a classificare la snackbar
/// e a far dipendere da quella scelta
/// (almeno) colore (e volendo anche icona,
/// testo, ecc.)
enum InfoType { success, error, info, warning }

/// classe InfoSnackBar.
/// Utilizzato per la visualizzazione di SnackBar
/// informative.
/// Permette di mostrare messaggi di feedback
/// all'utente specificando:
/// - il testo del messaggio
/// - la tipologia del messaggio (success, error, info, warning)
/// - la durata di visualizzazione
/// - un’eventuale azione associata (action label)
/// Passato il "type" come parametro
/// viene scelto di conseguenza il colore di
/// background.
/// La tipologia del messaggio determina automaticamente lo stile
/// della SnackBar (colore di sfondo e, se previsto, icona)
class InfoSnackBar {
  /// metodo statico "show".
  /// La classe "InfoSnackBar" è progettata come utility stateless;
  /// per questo motivo il metodo "show" è statico
  /// e può essere invocato senza istanziare la classe,
  /// evitando la gestione di stato non necessario
  static void show(
    /// riferimento alla posizione di un widget
    /// all'interno dell'albero dei widget di Flutter
    BuildContext context, {
    // messaggio informativo
    required String message,
    // tipologia di messaggio informativo
    required InfoType type,
    // action label
    String? actionLabel,
    // durata
    required Duration duration,
  }) {
    /// Recuperare lo "ScaffoldMessenger" associato
    /// allo schermo corrente
    final messenger = ScaffoldMessenger.of(context);

    /// Evitare "stack" di snackbar:
    /// ne mostri una per volta.
    /// Previene la sovrapposizione
    /// o l'accodamento automatico,
    /// garantendo una sola SnackBar
    /// visibile per volta
    messenger.hideCurrentSnackBar();

    /// ritorna una SnackBar
    messenger.showSnackBar(
      SnackBar(
        /// content (SnackBar)
        content: Text(
          // messaggio/avviso
          message,
          // stile
          style: TextStyle(
            // colore del messaggio avviso
            color: Colors.white,
            // grassetto
            fontWeight: FontWeight.bold,
          ),
        ),

        /// action (SnackBar)
        action: (actionLabel != null)
            ? SnackBarAction(label: actionLabel, onPressed: () {})
            : null,

        /// backgroundColor
        backgroundColor: _backgroundColor(type),

        /// posizionamento SnackBar
        behavior: SnackBarBehavior.floating,

        /// durata SnackBar
        /// decisa nel passaggio di parametri
        duration: duration,

        /// per definire la forma del bordo
        shape:
            /// tipo specifico di forma
            /// per creare bordi arrotondati
            RoundedRectangleBorder(
              /// definisce il raggio di arrotondamento
              /// di tutti e quattro gli angoli
              borderRadius: BorderRadius.circular(15),
            ),
      ),
    );
  }

  /// _backgroundColor
  /// Restituisce il colore di sfondo della SnackBar
  /// in base alla tipologia di messaggio ("InfoType")
  static Color _backgroundColor(InfoType type) {
    switch (type) {
      /// successo (verde scuro/green)
      case InfoType.success:
        // return Colors.green
        return const Color(0xFF2E7D32);

      /// errore (rosso/red)
      case InfoType.error:
        // return Colors.red;
        return const Color(0xFFC62828);

      /// warning (arancione/orange)
      case InfoType.warning:
        // return Colors.orange;
        return const Color(0xFFED6C02);

      /// info (blu/blue)
      case InfoType.info:
        // return Colors.blue;
        return const Color(0xFF1565C0);

      /// default (grigio/grey)
      default:
        // return Colors.grey;
        return const Color(0xFF9E9E9E);
    }
  }

  /// _icon (metodo statico non utilizzato/mai richiamato)
  /// Restituisce l'icona associata alla SnackBar
  /// in base alla tipologia di messaggio ("InfoType")
  static IconData _icon(InfoType type) {
    switch (type) {
      /// success
      case InfoType.success:
        return Icons.check_circle_outline;

      /// error
      case InfoType.error:
        return Icons.error_outline;

      /// warning
      case InfoType.warning:
        return Icons.warning_amber_rounded;

      /// default (in tutti gli altri casi)
      /// info
      default:
        return Icons.info_outline;
    }
  }
}
