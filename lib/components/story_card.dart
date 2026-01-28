import 'package:flutter/material.dart';
import 'package:hacker_news_api/models/story_model.dart';

/// StoryCard (refactoring del codice)
class StoryCard extends StatelessWidget {
  /// istanza specifica di StoryModel che devo mostrare nella Card
  final StoryModel story;

  /// In base al valore di refreshInProgress,
  /// gestisco il colore del bordo della Card.
  /// Durante il refresh -> bordo orange
  /// Altrimenti -> bordo green
  final bool refreshInProgress;

  /// costruttore
  const StoryCard({
    super.key,
    required this.story,
    required this.refreshInProgress,
  });

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return Card(
      // più "respiro" lateralmente + tenere le Card più vicine tra loro verticalmen.
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // nessuna ombreggiatura
      elevation: 0,
      shape: RoundedRectangleBorder(
        // questa Card non è un rettangolo secco, ma ha gli angoli arrotondati
        borderRadius: BorderRadius.circular(10),
        // proprietà bordo (Card)
        side: BorderSide(
          /// Colore bordo (Card)
          /// Bordo Card orange solo durante il refresh, altrimenti green
          color: refreshInProgress ? Colors.orange : Colors.green,
          // spessore bordo (Card)
          width: 2,
        ),
      ),
      // colore sfondo (Card)
      color: Colors.black,

      child: ListTile(
        /// title (ListTile)
        title: Text(
          story.title,
          // stile title (ListTile)
          style: const TextStyle(
            // colore title
            color: Colors.white,
            // grassetto title
            fontWeight: FontWeight.bold,
          ),
        ),

        /// subtitle (autore)
        subtitle: Text(
          // autore
          story.author,
          // stile di Text per autore
          style: const TextStyle(
            // colore subtitle
            color: Colors.white,
            // stile font subtitle
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
