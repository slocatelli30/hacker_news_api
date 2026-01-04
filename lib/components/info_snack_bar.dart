import 'package:flutter/material.dart';

/// enumerativi
/// TO DO - a cosa servono?
/// TO DO - dato che sono generali, vanno bene qui o meglio altrove?
enum InfoType { success, error, info, warning }

/// classe InfoSnackBar
/// TO DO - descrizione per capire a cosa serve
/// TO DO - passato il "type" come parametro
/// viene scelto di conseguenza il colore di
/// background
class InfoSnackBar {
  /// TO DO - descrizione
  static SnackBar show(
    // TO DO - SPIEGARE
    BuildContext context, {
    // TO DO
    required String message,
    // TO DO
    required InfoType type,
    // TO DO
    String? actionLabel,
    // TO DO
    required Duration duration,
  }) {
    /// Evitare "stack" di snackbar:
    /// ne mostri una per volta
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    return SnackBar(
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
    );
  }

  /// _backgroundColor
  /// TO DO - descrizione e a cosa serve
  static Color _backgroundColor(InfoType type) {
    switch (type) {
      /// successo
      case InfoType.success:
        // verde scuro - TO DO - da modificare eventualmente
        return const Color(0xFF2E7D32);

      /// errore
      case InfoType.error:
        // rosso scuro - TO DO - da modificare eventualmente
        return const Color(0xFFC62828);

      /// warning
      case InfoType.warning:
        // arancio - TO DO - da modificare eventualmente
        return const Color(0xFFED6C02);

      /// info
      case InfoType.info:
        // blu - TO DO - da modificare eventualmente
        return const Color(0xFF1565C0);

      /// default
      default:
        // grigio - TO DO - da modificare eventualmente
        return const Color(0xFF9E9E9E);
    }
  }

  /// _icon
  /// TO DO - descrizione e a cosa serve
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
