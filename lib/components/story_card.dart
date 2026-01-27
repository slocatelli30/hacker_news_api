import 'package:flutter/material.dart';
import 'package:hacker_news_api/models/story_model.dart';

/// StoryCard (refactoring del codice)
class StoryCard extends StatelessWidget {
  /// TO DO - perché questa variabile
  final StoryModel story;

  /// costruttore
  const StoryCard({super.key, required this.story});

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // nessuna ombreggiatura
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // proprietà bordo (Card)
        side: const BorderSide(
          // colore bordo (Card)
          color: Colors.green,
          // spessore bordo (Card)
          width: 2,
        ),
      ),
      // colore sfondo (Card)
      color: Colors.black,

      child: ListTile(
        /// title (titolo)
        title: Text(
          story.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        /// subtitle (autore)
        subtitle: Text(
          // autore
          story.author,
          // stile di Text per autore
          style: const TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
