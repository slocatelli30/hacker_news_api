/// import libreria http + alias
import 'package:http/http.dart' as http;

/// import dart convert
import 'dart:convert';

/// import modello dati
import 'package:hacker_news_api/models/story_model.dart';

/// import per debugPrint
import 'package:flutter/foundation.dart';

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
    final futures = topStoriesIds.map((int storyId) async {
      /// si deve iterare/ciclare per ciascun id/elemento
      /// e per ciascun id fare un'altra chiamata http

      try {
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
          debugPrint(
            "HackerNewsService: item $storyId "
            "HTTP ${response.statusCode} "
            "(${response.request?.url})",
          );
          return null;
        }

        /// Parsing JSON item
        dynamic decodedItem;
        try {
          decodedItem = json.decode(response.body);
        } on FormatException catch (e) {
          debugPrint(
            'HackerNewsService: item $storyId '
            'JSON non valido: $e ',
          );
          return null;
        }

        /// Distinguo il caso in cui "decodedItem" è null
        if (decodedItem == null) {
          debugPrint('HackerNewsService: item $storyId restituito null');
          return null;
        }

        /// Evita crash quando: HackerNews restituisce null,
        /// arriva payload non previsto, API cambia
        if (decodedItem is! Map<String, dynamic>) {
          debugPrint(
            'HackerNewsService: item $storyId '
            'payload non Map (${decodedItem.runtimeType})',
          );
          return null;
        }

        /// ritorna un'istanza di StoryModel
        /// invocando il metodo fromData
        return StoryModel.fromData(decodedItem);
      } catch (e, s) {
        debugPrint(
          'HackerNewsService: item $storyId '
          'errore inatteso: $e',
        );
        debugPrint(s.toString());
        return null;
      }
    }).toList();

    /// Attendo tutte le richieste
    final results = await Future.wait<StoryModel?>(futures);

    /// Tengo solo quelle valide
    final stories = results.whereType<StoryModel>().toList();

    // ritorno le stories
    return stories;
  }

  /// Recupera i dettagli di una singola story dato l'identificativo.
  /// Ritorna null se la story non è disponibile o il payload è invalido.
  Future<StoryModel?> fetchStoryById(int storyId) async {
    const timeoutDuration = Duration(seconds: 10);

    try {
      final response = await http
          .get(
            Uri.parse(
              "https://hacker-news.firebaseio.com/v0/item/$storyId.json?print=pretty",
            ),
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        debugPrint(
          "HackerNewsService: item $storyId "
          "HTTP ${response.statusCode} "
          "(${response.request?.url})",
        );
        return null;
      }

      dynamic decodedItem;
      try {
        decodedItem = json.decode(response.body);
      } on FormatException catch (e) {
        debugPrint("HackerNewsService: item $storyId JSON non valido: $e");
        return null;
      }

      if (decodedItem == null) {
        debugPrint("HackerNewsService: item $storyId restituito null");
        return null;
      }

      if (decodedItem is! Map<String, dynamic>) {
        debugPrint(
          "HackerNewsService: item $storyId payload non Map "
          "(${decodedItem.runtimeType})",
        );
        return null;
      }

      return StoryModel.fromData(decodedItem);
    } catch (e, s) {
      debugPrint("HackerNewsService: item $storyId errore inatteso: $e");
      debugPrint(s.toString());
      return null;
    }
  }
}
