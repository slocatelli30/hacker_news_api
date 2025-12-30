/// classe StoryModel
class StoryModel {
  // titolo
  final String title;
  // autore
  final String author;

  // costruttore
  StoryModel({
    // titolo
    required this.title,
    // autore
    required this.author,
  });

  /// metodo (factory) fromData con l'obiettivo di
  /// prendere i dati (data) e sapere come "costruirsi".
  /// Viene gestito il caso in cui i campi siano "null"
  /// o non String, così da evitare crash
  factory StoryModel.fromData(Map<String, dynamic> data) {
    // titolo
    final title = (data["title"] as String?) ?? "(senza titolo)";
    // autore
    final author = (data["by"] as String?) ?? "(autore sconosciuto)";

    // valore di ritorno (titolo e autore)
    return StoryModel(title: title, author: author);
  }
}
