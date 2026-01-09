// import libreria http + alias
import 'package:http/http.dart' as http;
// import dart convert
import 'dart:convert';
import 'package:hacker_news_api/models/story_model.dart';

/// classe HackerNewsService
/// contenente la logica HTTP/JSON,
/// logica applicativa/interfacciamento esterno.
/// Questa classe gestisce la logica per interfacciarsi
/// con il servizio esterno, come la chiamata HTTP
/// per recuperare i dati da Hacker News
class HackerNewsService {
  /// numero di topStories da prendere
  final int _firstTopStories = 15;

  /// metodo downloadStoryData
  Future<List<StoryModel>> downloadStoryData() async {
    /// variabile che evita: app bloccata,
    /// spinner infinito e UX pessima su rete lenta
    const timeoutDuration = Duration(seconds: 10);

    /// chiamata http per prendere le topstories
    final topStoriesResponse = await http
        // get
        .get(
          Uri.parse(
            "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty",
          ),
        )
        // timeout
        .timeout(timeoutDuration);

    /// Controllo status code
    /// Service fallisce in modo controllato
    if (topStoriesResponse.statusCode != 200) {
      throw Exception(
        "Errore HTTP ${topStoriesResponse.statusCode} su topstories",
      );
    }

    /// Parsing JSON topstories
    /// Alla fine dell'istruzione non metto
    /// "as List<dynamic>", perché non sono
    /// sicuro che questo è una List.
    /// Se il body non è JSON valido, json.decode
    /// lancia FormatException
    dynamic decodedTopStories;
    try {
      decodedTopStories = json.decode(topStoriesResponse.body);
    } on FormatException catch (e) {
      throw Exception("JSON non valido per topstories: $e");
    }

    /// Controllo che "decodedTopStories" sia una lista.
    /// Se non lo è (se non è una List), allora considero
    /// il payload non valido e fallisco.
    /// Se è una List -> ok, continuo
    /// Se è null, Map, String, int, ... -> errore controllato
    if (decodedTopStories is! List) {
      throw Exception("Formato non valido per topstories");
    }

    /// Prendo solo i primi firstTopStories id
    /// e controllo che la lista contenga int
    final topStoriesIds = decodedTopStories
        .whereType<int>()
        .take(_firstTopStories)
        .toList();

    /// Chiamate parallele per i dettagli delle stories
    final futures = topStoriesIds.map((storyId) async {
      /// si deve iterare/ciclare per ciascun id/elemento
      /// e per ciascun id fare un'altra chiamata http

      /// altra chiamata http per ciascun id, http.get
      final response = await http
          .get(
            Uri.parse(
              "https://hacker-news.firebaseio.com/v0/item/$storyId.json?print=pretty",
            ),
          )
          .timeout(timeoutDuration);

      /// Controllo status code item
      if (response.statusCode != 200) {
        throw Exception("Errore HTTP ${response.statusCode} su item $storyId");
      }

      /// Parsing JSON item
      dynamic decodedItem;
      try {
        decodedItem = json.decode(response.body);
      } on FormatException catch (e) {
        throw Exception("JSON non valido per item $storyId: $e");
      }

      /// Evita crash quando: HackerNews restituisce null,
      /// arriva payload non previsto, API cambia
      if (decodedItem is! Map<String, dynamic>) {
        throw Exception("Item $storyId non valido");
      }

      /// ritorna un'istanza di StoryModel
      /// invocando il metodo fromData
      return StoryModel.fromData(decodedItem);
    }).toList();

    /// Attendo tutte le richieste
    final stories = await Future.wait(futures);

    // ritorno le stories
    return stories;
  }
}
