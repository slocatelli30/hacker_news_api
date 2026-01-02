import 'package:flutter/material.dart';
import 'package:hacker_news_api/pages/partials/custom_app_bar.dart';
import 'package:hacker_news_api/pages/partials/error_info_page.dart';
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

  /// TO DO
  bool _isRefreshing = false;

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
  Future<void> refreshData() async {
    /// TO DO
    _isRefreshing = true;

    // setState
    setState(() {
      /// refresh manuale di storyModelFuture
      _loadStories();
    });

    /// Aspetto che il FutureBuilder riceva
    /// il nuovo future e lo completi.
    /// Per far sì che l'animazione del RefreshIndicator
    /// rimanga finché il download non finisce
    try {
      await storyModelFuture;
    } catch (_) {
      // ignora: il FutureBuilder gestirà snapshot.hasError
      // TO DO - EVENTUALE TIMEOUT DA QUALCHE PARTE?
    } finally {
      _isRefreshing = false;
    }
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

      // colore di sfondo (Scaffold)
      backgroundColor: Colors.white,
    );
  }

  /// body: componente personalizzato
  Widget body() => FutureBuilder<List<StoryModel>>(
    /// future su cui ci si mette in ascolto
    future: storyModelFuture,
    // builder
    builder: (context, snapshot) {
      /// 1. Loading
      /// TO DO - PER AGGIUNTA MODIFICA
      if (snapshot.connectionState == ConnectionState.waiting &&
          !_isRefreshing) {
        // ritorna la pagina di caricamento/loading
        return const LoadingPage();
      }

      /// 2. Error
      if (snapshot.hasError) {
        return ErrorInfoPage(
          infoText: "Errore nel caricamento",
          buttonText: "Riprova",
          onRefresh: refreshData,
        );
      }

      /// 3. No data (null)
      /// Da qui in poi, si utilizza "stories"
      /// evitando così "snapshot.data!" perché
      /// "pericoloso"
      final stories = snapshot.data;
      if (stories == null) {
        return ErrorInfoPage(
          infoText: "Nessun dato disponibile",
          buttonText: "Ricarica",
          onRefresh: refreshData,
        );
      }

      /// 4. Empty list
      if (stories.isEmpty) {
        return ErrorInfoPage(
          infoText: "Nessuna news trovata",
          buttonText: "Aggiorna",
          onRefresh: refreshData,
        );
      }

      /// 5. Success (tutto ok)
      // ritorna un Container
      return RefreshIndicator(
        /// TO DO
        onRefresh: refreshData,

        /// colore della freccia/spinner
        color: Colors.white,

        /// colore di sfondo del cerchio
        backgroundColor: Colors.green,

        /// child: ListView (variante separated)
        child: ListView.separated(
          /// TO DO
          physics: const AlwaysScrollableScrollPhysics(),

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
          /// divisore tra una news e l'altra
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey.shade300),
        ),
      );
    },
  );
}
