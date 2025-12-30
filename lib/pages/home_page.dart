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
    _loadStories();
  }

  /// _loadStories
  /// metodo privato per il download delle stories
  void _loadStories() {
    storyModelFuture = _service.downloadStoryData();
  }

  /// metodo refreshData per aggiornare la lista delle stories
  void refreshData() {
    // setState
    setState(() {
      /// refresh manuale di storyModelFuture
      _loadStories();
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
      /// 1. Loading
      if (snapshot.connectionState == ConnectionState.waiting) {
        // ritorna la pagina di caricamento/loading
        return const LoadingPage();
      }

      /// 2. Error
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Si è verificato un errore nel caricamento"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: refreshData,
                child: const Text("Riprova"),
              ),
            ],
          ),
        );
      }

      /// 3. No data (null)
      /// Da qui in poi, si utilizza "stories"
      /// evitando così "snapshot.data!" perché
      /// "pericoloso"
      final stories = snapshot.data;
      if (stories == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nessun dato disponibile"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: refreshData,
                child: const Text("Ricarica"),
              ),
            ],
          ),
        );
      }

      /// 4. Empty list
      if (stories.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nessuna news trovata"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: refreshData,
                child: const Text("Aggiorna"),
              ),
            ],
          ),
        );
      }

      /// 5. Success (tutto ok)
      // ritorna un Container
      return Container(
        /// colore Container
        color: Colors.white,

        /// child: ListView (variante separated)
        child: ListView.separated(
          /// itemCount
          itemCount: stories.length,

          /// itemBuilder
          itemBuilder: (context, index) => ListTile(
            /// title (titolo)
            title: Text(
              stories[index].title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            /// subtitle (autore)
            subtitle: Text(
              // autore
              stories[index].author,
              // stile di Text per autore
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

          /// separatorBuilder
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey.shade300),
        ),
      );
    },
  );
}
