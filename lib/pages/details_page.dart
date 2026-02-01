import 'package:flutter/material.dart';
import 'package:hacker_news_api/models/story_model.dart';
import 'package:hacker_news_api/services/hacker_news_service.dart';

/// import per aprire link url nel browser
import 'package:url_launcher/url_launcher.dart';

/// TO DO - descrizione
class DetailsPage extends StatefulWidget {
  /// TO DO - descrizione sensata del perché
  final int storyId;

  /// costruttore
  const DetailsPage({super.key, required this.storyId});

  /// override del metodo createState
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

/// TO DO - ...
class _DetailsPageState extends State<DetailsPage> {
  /// TO DO - ...
  final HackerNewsService _service = HackerNewsService();

  /// TO DO - ...
  late final Future<StoryModel?> _storyFuture;

  /// TO DO
  Future<void> _openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);

    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("URL non valido")));
      return;
    }

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // apre nel browser
    );

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossibile aprire il link")),
      );
    }
  }

  /// override del metodo initState
  @override
  void initState() {
    // initState
    super.initState();
    // TO DO
    // TO DO - widget.storyId ???
    _storyFuture = _service.fetchStoryById(widget.storyId);
  }

  /// override del metodo build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dettaglio notizia")),
      body: FutureBuilder<StoryModel?>(
        future: _storyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

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

          final story = snapshot.data;

          /// TO DO - da cancellare dopo i test
          print("******* ${story?.text} ******* ${story?.url} *******");

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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                story.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              Text(
                "di ${story.author} • id: ${story.id}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              if (story.url != null) ...[
                ElevatedButton.icon(
                  // aprire l'url
                  onPressed: () => _openUrl(story.url!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Apri articolo"),
                ),
                const SizedBox(height: 16),
              ],

              if (story.text != null) ...[
                Text(story.text!, style: Theme.of(context).textTheme.bodyLarge),
              ] else ...[
                const Text("Nessun testo disponibile."),
              ],
            ],
          );
        },
      ),
    );
  }
}
