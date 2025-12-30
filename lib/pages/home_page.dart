import 'package:flutter/material.dart';
import 'package:hacker_news_api/pages/partials/custom_app_bar.dart';
import 'package:hacker_news_api/pages/partials/loading_page.dart';
// import story_model.dart
import 'package:hacker_news_api/models/story_model.dart';
import 'package:hacker_news_api/services/hacker_news_service.dart';

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

  /// "service" variabile privata che contiene
  /// un'istanza di "HackerNewsService"
  /// e sarà utilizzata per invocare
  /// i metodi di quella classe
  final _service = HackerNewsService();

  /// override del metodo initState
  @override
  void initState() {
    // super initState
    super.initState();

    /// prima inizializzazione di storyModelFuture
    storyModelFuture = _service.downloadStoryData();
  }

  /// metodo refreshData per aggiornare la lista delle stories
  void refreshData() {
    // setState
    setState(() {
      /// refresh manuale di storyModelFuture
      storyModelFuture = _service.downloadStoryData();
    });
  }

  // override del metodo build
  @override
  Widget build(BuildContext context) {
    /// Scaffold
    return Scaffold(
      /// appBar custom
      appBar: CustomAppBar(onRefresh: refreshData),

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
        // ritorna la pagina di caricamento/loading
        return LoadingPage();
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
              title: Text(
                snapshot.data![index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

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
