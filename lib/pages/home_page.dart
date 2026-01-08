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

  /// variabile di stato che rappresenta
  /// se c'è un refresh in corso o meno.
  /// Inizializzata a "false", perché all'avvio
  /// non c'è nessun refresh in corso.
  /// Stato iniziale: non sto ricaricando nulla
  bool _refreshInProgress = false;

  /// override del metodo initState
  @override
  void initState() {
    // super initState
    super.initState();

    /// Inizializzare i dati della pagina.
    /// Serve sapere quando finisce il Future
    /// per popolare la cache, senza mostrare SnackBar
    _loadInitial();
  }

  /// Metodo che serve a caricare i dati al primo avvio
  /// della pagina, mostrando il "LoadingPage", senza
  /// SnackBar, e popolando la cache quando i dati arrivano.
  /// Diverso dal refresh manuale perché:
  /// - non deve mostrare feedback all'utente (SnackBar)
  /// - deve solo "portare la pagina da vuota -> lista".
  /// Qui non decido cosa mostrare ma preparo lo stato.
  /// La UI reagisce leggendo quello stato.
  /// Scopo: inizializzare i dati della pagina.
  /// Avvia il caricamento iniziale, mostra il loading,
  /// quando i dati arrivano aggiorna lo stato,
  /// se fallisce lascia che la UI gestisca l'errore
  void _loadInitial() {
    /// Avvio del download
    /// Avvio chiamata asincrona + salvo il Future nello stato
    /// -> il FutureBuilder reagisce.
    /// Avvio del Future
    storyModelFuture = _service.downloadStoryData();

    storyModelFuture
        /// quando il Future va a buon fine,
        /// aggiorno la cache e faccio rebuild.
        /// ".then" = quando questo Future
        /// si completa con successo, esegui questa funzione.
        /// "stories" = risultato finale "List<StoryModel>".
        /// Quando il Future termina...
        .then((stories) {
          /// se questa pagina non esiste più, non fare nulla
          if (!mounted) return;

          /// aggiornamento dello stato (cache) +
          /// Flutter fa un rebuild della UI.
          /// Aggiorna lo stato dell'applicazione...
          setState(() {
            _storiesCache = stories;
          });
        })
        /// quando il Future fallisce,
        /// non faccio nulla -> la UI gestisce l'errore.
        /// Intercetta solo errori del Future, evita crash e
        /// non mostra SnackBar
        .catchError((Object e, StackTrace s) {
          // Qui non serve SnackBar: il builder mostrerà ErrorInfoPage al primo avvio
        });
  }

  /// Metodo che serve a gestire un refresh manuale
  /// (tap sul bottone in AppBar o pull-to-refresh)
  /// con questi obiettivi:
  /// - evitare refresh multipli in parallelo (spam di tap/gesture)
  /// - far partire una nuova richiesta al service
  /// e aggiornare "storyModelFuture"
  /// (così il "FutureBuilder" sa che c'è un nuovo caricamento)
  /// - Aspettare il risultato della richiesta
  /// (così il "RefreshIndicator" resta attivo
  /// finché il download finisce)
  /// - Se "successo": aggiornare la cache ("_storiesCache")
  /// e mostrare relativa SnackBar
  /// - Se "errore": mantenere la lista precedente (cache)
  /// e mostrare relativa SnackBar
  /// - Alla fine: sbloccare il refresh ("_refreshInProgress = false")
  /// sempre, in ogni caso
  Future<void> refreshData() async {
    /// Se un refresh è già in corso,
    /// ignora nuovi refresh.
    /// Evita richieste multiple in parallelo, SnackBar multiple
    /// e race condition
    if (_refreshInProgress) return;

    /// altrimenti, se non è in corso,
    /// ne avii uno.
    /// Accetto un refresh solo se non
    /// ce n'è già uno attivo.
    /// Segno che "da adesso in poi" un refresh è attivo.
    /// Qui non serve "setState", perché questa variabile
    /// non cambia la UI (serve solo come lock logico)
    _refreshInProgress = true;

    /// future specifico di questo refresh.
    /// final -> lo assegni una sola volta
    /// late -> lo assegni dopo (dentro "setState")
    late final Future<List<StoryModel>> future;

    /// Questo blocco fa due cose sincronizzate:
    /// - avvia la richiesta
    /// - aggiorna la variabile osservata dal "FutureBuilder"
    setState(() {
      // avvio download/avvio richiesta
      future = _service.downloadStoryData();
      // notifica la UI
      storyModelFuture = future;
    });

    try {
      /// "await future" fa sì che:
      /// - il metodo non termina subito
      /// - lo spinner del "RefreshIndicator" resta visibile
      /// finché finisce il download
      /// - evito che la funzione torni prima del tempo
      final freshStories = await future;

      /// se la pagina è stata chiusa nel frattempo,
      /// non devo toccare lo stato né mostrare SnackBar
      if (!mounted) return;

      /// Qui aggiorno la "fonte di verità" della lista visibile.
      /// Flutter rifà build -> lista aggiornata
      setState(() {
        _storiesCache = freshStories;
      });

      /// Feedback all'utente: refresh completato
      InfoSnackBar.show(
        context,
        message: "Lista aggiornata correttamente",
        type: InfoType.success,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      /// Se la richiesta fallisce, entri qui

      /// Se la pagina non esiste più, non fare nulla
      if (!mounted) return;

      /// Mostrare messaggio di errore ma non si tocca la cache.
      /// Risultato UX: l'utente resta con la lista vecchia
      /// (se c'era) e sa che il refresh non è andato a buon fine
      InfoSnackBar.show(
        context,
        message: "Errore durante l'aggiornamento",
        type: InfoType.error,
        duration: const Duration(seconds: 2),
      );
    } finally {
      /// Sbloccare sempre (fondamentale)
      _refreshInProgress = false;
    }
  }

  /// override del metodo build
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
