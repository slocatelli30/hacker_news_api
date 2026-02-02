/// Widget Material di base
import 'package:flutter/material.dart';

/// Modello dati della news
import 'package:hacker_news_api/models/story_model.dart';

/// Servizio per il recupero dati da Hacker News
import 'package:hacker_news_api/services/hacker_news_service.dart';

/// Plugin per l'apertura di URL esterni
/// -> import per aprire link url nel browser
import 'package:url_launcher/url_launcher.dart';

/// Pagina di dettaglio di una singola news
class DetailsPage extends StatefulWidget {
  /// Identificativo della news da caricare
  final int storyId;

  /// costruttore con:
  /// - id obbligatorio
  const DetailsPage({super.key, required this.storyId});

  /// Creazione dello stato associato al widget
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

/// Stato della pagina di dettaglio
class _DetailsPageState extends State<DetailsPage> {
  /// Servizio per le chiamate API
  final HackerNewsService _service = HackerNewsService();

  /// Future per il recupero asincrono della news
  late final Future<StoryModel?> _storyFuture;

  /// Apre un URL nel browser esterno
  Future<void> _openUrl(String urlString) async {
    /// Parsing sicuro dell'URL
    final uri = Uri.tryParse(urlString);

    /// Validazione schema URL
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("URL non valido")));
      return;
    }

    /// Tentativo di apertura nel browser
    final ok = await launchUrl(
      uri,
      // apertura nel browser
      mode: LaunchMode.externalApplication,
    );

    /// Gestione errore apertura link
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossibile aprire il link")),
      );
    }
  }

  /// Inizializzazione dello stato
  @override
  void initState() {
    // initState
    super.initState();

    /// Avvio caricamento news tramite id
    _storyFuture = _service.fetchStoryById(widget.storyId);
  }

  /// Costruzione UI della pagina
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // colore sfondo pagina dettagli
      backgroundColor: Colors.black,

      appBar: AppBar(
        // titolo pagina dettagli
        title: const Text("Dettaglio notizia"),
        // colore contenuti/elementi in primo piano
        foregroundColor: Colors.white,
        // colore sfondo AppBar in pagina dettagli
        backgroundColor: Colors.black,
      ),

      /// Gestione stato asincrono della chiamata API
      body: FutureBuilder<StoryModel?>(
        future: _storyFuture,
        builder: (context, snapshot) {
          /// Stato di caricamento
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          /// Stato di errore
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Errore nel caricamento: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          /// Dato restituito dal Future
          final story = snapshot.data;

          /// Gestione news assente
          if (story == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Contenuto non disponibile.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          /// Layout scrollabile dei contenuti
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// titolo news
              Text(
                // testo titolo news
                story.title,
                // stile testo titolo news
                style: TextStyle(color: Colors.white),
              ),

              /// spaziatura verticale
              const SizedBox(height: 8),

              /// autore + id news
              Text(
                "by ${story.author} • id: ${story.id}",
                // stile testo di autore + id news
                style: TextStyle(
                  // colore testo di autore + id news
                  color: Colors.white,
                  // stile font testo di autore + id news
                  fontStyle: FontStyle.italic,
                ),
              ),

              /// spaziatura verticale
              const SizedBox(height: 16),

              /// Pulsante apertura articolo (se presente URL)
              if (story.url != null) ...[
                ElevatedButton.icon(
                  // aprire link esterno
                  onPressed: () => _openUrl(story.url!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Apri articolo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              /// Testo della news o fallback
              if (story.text != null) ...[
                Text(story.text!, style: TextStyle(color: Colors.white)),
              ] else ...[
                const Text(
                  "No text provided by Hacker News.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
