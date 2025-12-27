import 'package:flutter/material.dart';
// import libreria http + alias
import 'package:http/http.dart' as http;
// import dart convert
import 'dart:convert';
// import story_model.dart
import 'package:hacker_news_api/models/story_model.dart';

/// classe HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // override del metodo createState
  @override
  State<HomePage> createState() => _HomePageState();
}

/// classe HomePageState
class _HomePageState extends State<HomePage> {
  /// variabile di stato storyModelFuture che conterrà
  /// un qualcosa che verrà risolto in futuro e quel
  /// qualcosa è un'istanza di StoryModel
  late Future<List<StoryModel>> storyModelFuture;

  /// numero di topStories da prendere
  final int firstTopStories = 15;

  // override del metodo initState
  @override
  void initState() {
    // super initState
    super.initState();

    /// inizializzazione di storyModelFuture
    storyModelFuture = downloadStoryData();
  }

  /// metodo downloadStoryData
  Future<List<StoryModel>> downloadStoryData() async {
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

  /// metodo refreshData per aggiornare la lista delle stories
  void refreshData() {
    // setState
    setState(() {
      ///
      storyModelFuture = downloadStoryData();
    });
  }

  // override del metodo build
  @override
  Widget build(BuildContext context) {
    /// Scaffold
    return Scaffold(
      // appBar
      appBar: AppBar(
        /// title di AppBar
        title: Text(
          "News!",
          // style di Text
          style: TextStyle(color: Colors.black),
        ),

        actions: [
          IconButton(
            // onPressed per il refresh
            onPressed: refreshData,
            // icona di refresh
            icon: Icon(Icons.refresh),
          ),
        ],

        /// Title al centro (AppBar)
        centerTitle: true,

        /// colore di sfondo (AppBar)
        backgroundColor: Colors.white,
      ),

      /// body
      body: Center(
        /// child
        child: body(),
      ),
    );
  }

  /// body: componente personalizzato
  Widget body() => FutureBuilder<List<StoryModel>>(
    /// future su cui ci si mette in ascolto
    future: storyModelFuture,
    // builder
    builder: (context, snapshot) {
      /// se questa future non è stata ancora risolta
      if (snapshot.connectionState != ConnectionState.done) {
        // caricamento/loading
        return CircularProgressIndicator();
      } else {
        // ritorna un Container
        return Container(
          /// colore Container
          color: Colors.white,

          /// child: ListView (variante separated)
          child: ListView.separated(
            /// itemCount
            itemCount: snapshot.data!.length,

            /// itemBuilder
            itemBuilder: (context, index) => ListTile(
              /// title (titolo)
              title: Text(snapshot.data![index].title),

              /// subtitle (autore)
              subtitle: Text(
                // autore
                snapshot.data![index].author,
                // stile di Text per autore
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            /// separatorBuilder
            separatorBuilder: (context, index) => Divider(color: Colors.white),
          ),
        );
      }
    },
  );
}
