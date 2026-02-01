/// classe StoryModel
class StoryModel {
  // id
  final int id;
  // titolo
  final String title;
  // autore (by)
  final String author;
  // testo
  final String? text;
  // url
  final String? url;

  // costruttore
  StoryModel({
    // id
    required this.id,
    // titolo
    required this.title,
    // autore (by)
    required this.author,
    // testo
    this.text,
    // url
    this.url,
  });

  /// metodo (factory) fromData con l'obiettivo di
  /// prendere i dati (data) e sapere come "costruirsi".
  /// Viene gestito il caso in cui i campi siano "null"
  /// o non String, così da evitare crash
  factory StoryModel.fromData(Map<String, dynamic> data) {
    // id
    final id = data["id"] as int;
    // titolo
    final title = (data["title"] as String?) ?? "(senza titolo)";
    // autore (by)
    final author = (data["by"] as String?) ?? "(autore sconosciuto)";
    // testo
    final text = data["text"] as String?;
    // url
    final url = data["url"] as String?;

    // valore di ritorno (titolo e autore)
    return StoryModel(
      id: id,
      title: title,
      author: author,
      text: text,
      url: url,
    );
  }
}
