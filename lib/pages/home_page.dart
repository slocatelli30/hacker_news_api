import 'package:flutter/material.dart';
import 'package:hacker_news_api/components/info_snack_bar.dart';
import 'package:hacker_news_api/pages/partials/custom_app_bar.dart';
import 'package:hacker_news_api/pages/partials/error_info_page.dart';
import 'package:hacker_news_api/pages/partials/loading_page.dart';
// import story_model.dart
import 'package:hacker_news_api/models/story_model.dart';
import 'package:hacker_news_api/services/hacker_news_service.dart';

/// classe HomePage
/// Widget di alto livello che coordina lo stato,
/// la logica di caricamento dati e la composizione
/// dei componenti grafici della HomePage
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

  /// Cache dell’ultima lista valida mostrata.
  /// Se non è null, NON mostriamo mai LoadingPage durante refresh.
  List<StoryModel>? _storiesCache;

  /// override del metodo initState
  @override
  void initState() {
    // super initState
    super.initState();

    // download delle stories
    storyModelFuture = _service.downloadStoryData();
  }

  /// metodo refreshData per aggiornare la lista delle stories
  Future<void> refreshData() async {
    /// setState
    /// Scateno un nuovo Future per il FutureBuilder
    /// (senza cambiare UI in loading)
    setState(() {
      /// refresh manuale di storyModelFuture
      storyModelFuture = _service.downloadStoryData();
    });

    /// Aspetto il risultato per:
    /// - far durare lo spinner del RefreshIndicator
    /// quanto il download
    /// - mostrare SnackBar a fine refresh
    try {
      /// Aspetto che il FutureBuilder riceva
      /// il nuovo future e lo completi, così
      /// che l'animazione del RefreshIndicator
      /// rimanga finché il download non finisce.
      /// In questo modo l'animazione dura
      /// esattamente quanto il download
      final freshStories = await storyModelFuture;

      /// Se questo State non è più montato,
      /// esci immediatamente dal metodo,
      /// così da evitare crash
      if (!mounted) return;

      /// Aggiorno la cache solo se ho dati validi
      setState(() {
        _storiesCache = freshStories;
      });

      /// Mostrare la SnackBar personalizzata
      /// SOLO su refresh manuale
      /// (AppBar o pull-to-refresh)
      InfoSnackBar.show(
        // context
        context,
        // messaggio
        message: "Lista aggiornata correttamente",
        // tipo di messaggio
        type: InfoType.success,
        // durata
        duration: Duration(seconds: 2),
      );
    } catch (_) {
      /// ignora: il FutureBuilder gestirà snapshot.hasError
      /// eventuale timeout va gestito nel service

      /// Se questo State non è più montato,
      /// esci immediatamente dal metodo,
      /// così da evitare crash
      if (!mounted) return;

      /// Mostrare la SnackBar personalizzata
      /// se fallisce il refresh, mantenendo la lista precedente
      InfoSnackBar.show(
        // context
        context,
        // messaggio
        message: "Errore durante l'aggiornamento",
        // tipo di messaggio
        type: InfoType.error,
        // durata
        duration: Duration(seconds: 2),
      );
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
      /// Se arrivano dati, aggiorno cache
      /// (vale sia per primo load sia per refresh)
      if (snapshot.hasData) {
        _storiesCache = snapshot.data;
      }

      /// 1. Loading
      /// SOLO primo avvio: nessuna cache + waiting
      if (_storiesCache == null &&
          snapshot.connectionState == ConnectionState.waiting) {
        // ritorna la pagina di caricamento/loading
        return const LoadingPage();
      }

      /// 2. Error
      /// Se c'è errore al primo avvio (nessuna cache),
      /// mostra pagina di errore
      if (snapshot.hasError && _storiesCache == null) {
        return ErrorInfoPage(
          infoText: "Errore nel caricamento",
          buttonText: "Riprova",
          onRefresh: refreshData,
        );
      }

      /// Da qui in poi: ho cache
      /// (oppure sono in una situazione "strana")
      final stories = _storiesCache;

      /// 3. No data (null)
      /// per sicurezza, in pratica non si dovrebbe quasi mai
      /// arrivare qui
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
      /// Lista sempre visibile + pull-to-refresh
      /// - Tap AppBar: nessuna LoadingPage, lista resta lì,
      /// poi SnackBar
      /// - Pull-to-refresh: spinner RefreshIndicator,
      /// poi SnackBar
      return RefreshIndicator(
        /// Regola fondamentale del RefreshIndicator:
        /// - "onRefresh" DEVE restituire un Future<void>
        /// - lo spinner resta visibile finché il Future non termina

        /// Collegamento tra il gesto dell'utente
        /// (pull-down) e il metodo refreshData()
        onRefresh: refreshData,

        /// colore della freccia/spinner
        color: Colors.white,

        /// colore di sfondo del cerchio
        backgroundColor: Colors.green,

        /// child: ListView (variante separated)
        child: ListView.separated(
          /// la lista deve essere scrollabile anche se
          /// il contenuto non riempie lo schermo
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
