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
  /// prendere i dati (data) e sapere come "costruirsi"
  factory StoryModel.fromData(Map<String, dynamic> data) {
    // titolo
    final title = data["title"];
    // autore
    final author = data["by"];

    // valore di ritorno (titolo e autore)
    return StoryModel(title: title, author: author);
  }
}
