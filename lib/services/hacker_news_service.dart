// import libreria http + alias
import 'package:http/http.dart' as http;
// import dart convert
import 'dart:convert';
import 'package:hacker_news_api/models/story_model.dart';

/// classe HackerNewsService
/// contenente la logica HTTP/JSON,
/// logica applicativa/interfacciamento esterno
class HackerNewsService {
  /// metodo downloadStoryData
  Future<List<StoryModel>> downloadStoryData({
    // firstTopStories (parametro richiesto)
    required int firstTopStories,
  }) async {
    /// chiamata http per prendere le topstories
    final topStoriesHttpResponse = await http.get(
      Uri.parse(
        "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty",
      ),
    );

    /// parsing di topStoriesHttpResponse
    /// che restituisce una lista di interi (id)
    final topStoriesIds =
        json.decode(topStoriesHttpResponse.body) as List<dynamic>;

    /// ciascuno di questi id viene mappato
    /// (si prendono solamente le prime firstTopStories)
    final topStoriesFutures = topStoriesIds.take(firstTopStories).map((
      storyId,
    ) async {
      /// si deve iterare/ciclare per ciascun id/elemento
      /// e per ciascun id fare un'altra chiamata http

      /// altra chiamata http per ciascun id, http.get
      final response = await http.get(
        Uri.parse(
          "https://hacker-news.firebaseio.com/v0/item/$storyId.json?print=pretty",
        ),
      );

      /// storyData: risultato di json.decode
      /// e parsing del json
      final storyData = json.decode(response.body);

      /// ritorna un'istanza di StoryModel
      /// invocando il metodo fromData
      return StoryModel.fromData(storyData);
    }).toList();

    /// aspettare che le topStoriesFutures si completino,
    /// ovvero si aspetta che tutte le chiamate http che
    /// avvengono in parallelo (e che prendono i dettagli
    /// delle stories) vengano completate
    final topStories = await Future.wait(topStoriesFutures);

    // valore di ritorno
    return topStories;
  }
}
