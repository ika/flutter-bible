part of 'page.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key, required this.model});

  final Bible model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    //debugPrint('Bible model: id=${model.id}, book=${model.book}, chapter=${model.chapter}, verse=${model.verse}, version=${model.version}, text=${model.text}');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            "${BibleBooks.getBookAbbrByNumber(model.book)} ${model.chapter}:${model.verse}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          (Globals.bibleVersionLanguage == 'lat')
              ? GestureDetector(
                  onTap: () {
                    // 1. Close the BottomSheet first
                    Navigator.pop(context);
                    // 2. Open the Dialog as a standalone route
                    showDialog(
                      context: context,
                      builder: (context) =>
                          WordSearchWidget(verseText: model.text),
                    );
                  },
                  child: Text(
                    model.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Text(
                  model.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.compare),
            title: const Text('Compare Verse'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => ParallelVersesSheet(
                  text: model.text,
                  book: model.book,
                  chapter: model.chapter,
                  verse: model.verse,
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmark Verse'),
            onTap: () async {
              Navigator.pop(context);
              final existingId = await _getExistingCacheId(1);
              if (existingId != null) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Already bookmarked')),
                );
              } else {
                await _addCacheEntry(1).then((_) {
                  if (context.mounted) {
                    context.read<VerseBloc>().add(
                      UpdateVerse(verseNumber: model.verse),
                    );
                  }
                  Globals.refreshNotifier.refresh();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Bookmark saved')),
                  );
                });
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.highlight),
            title: const Text('Highlight Verse'),
            onTap: () async {
              Navigator.pop(context);
              final existingId = await _getExistingCacheId(2);
              if (existingId != null) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Already highlighted')),
                );
              } else {
                await _addCacheEntry(2).then((_) {
                  if (context.mounted) {
                    context.read<VerseBloc>().add(
                      UpdateVerse(verseNumber: model.verse),
                    );
                  }
                  Globals.refreshNotifier.refresh();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Highlight saved')),
                  );
                });
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Verse'),
            onTap: () {
              Navigator.pop(context);
              final fullText =
                  '${model.text} ${BibleBooks.getBookNameByNumber(model.book)} ${model.chapter}:${model.verse}';
              Clipboard.setData(ClipboardData(text: fullText));
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Text copied')),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Future<int?> _getExistingCacheId(int code) async {
    return await isar.caches
        .filter()
        .versionEqualTo(model.version)
        .bookEqualTo(model.book)
        .chapterEqualTo(model.chapter)
        .verseEqualTo(model.verse)
        .codeEqualTo(code)
        .idProperty()
        .findFirst();
  }

  Future<void> _addCacheEntry(int code) async {
    final entry = Cache()
      ..id = model.id
      ..version = model.version
      ..book = model.book
      ..chapter = model.chapter
      ..verse = model.verse
      ..text = model.text
      ..code = code;
    await isar.writeTxn(() => isar.caches.put(entry));
  }
}

/// Standalone Dialog Widget that manages its own search state
class WordSearchWidget extends StatefulWidget {
  const WordSearchWidget({super.key, required this.verseText});

  final String verseText;

  @override
  State<WordSearchWidget> createState() => WordSearchWidgetState();
}

class WordSearchWidgetState extends State<WordSearchWidget> {
  final ValueNotifier<List<Word>> _resultsNotifier = ValueNotifier([]);

  @override
  void dispose() {
    _resultsNotifier.dispose();
    super.dispose();
  }

  // Future<void> _fetchWordData(String query) async {
  //   if (query.isEmpty) {
  //     _resultsNotifier.value = [];
  //     return;
  //   }
  //
  //   final isarQuery = query.length >= 4 ? query.substring(0, 4) : query;
  //
  //   try {
  //     final results = await isar.words
  //         .filter()
  //         .latStartsWith(isarQuery, caseSensitive: false)
  //         .findAll();
  //
  //     if (mounted) {
  //       _resultsNotifier.value = results;
  //     }
  //   } catch (e) {
  //     debugPrint('Search error: $e');
  //   }
  // }

  Future<void> _fetchWordData(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        _resultsNotifier.value = [];
      }
      return;
    }

    List<Word> results = [];
    String searchString = query.trim();

    while (searchString.isNotEmpty) {
      try {
        results = await isar.words
            .filter()
            .latStartsWith(searchString, caseSensitive: false)
            .findAll();

        if (results.isNotEmpty) {
          break; // Found results, exit loop.
        }

        // If no results, shorten the query from the end for the next iteration.
        searchString = searchString.substring(0, searchString.length - 1);
      } catch (e) {
        debugPrint('Search error: $e');
        results = []; // Clear results on error
        break; // Exit loop on error
      }
    }

    if (mounted) {
      _resultsNotifier.value = results;
    }
  }

  Widget _makeWordsClickable(String text) {
    final words = text.split(RegExp(r'\s+'));
    return Wrap(
      alignment: WrapAlignment.center,
      children: words.map((word) {
        return GestureDetector(
          onTap: () {
            final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
            _fetchWordData(cleanWord);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text('$word ', style: const TextStyle(fontSize: 18)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.translate, color: colorScheme.primary),
      title: _makeWordsClickable(widget.verseText),
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: ValueListenableBuilder<List<Word>>(
          valueListenable: _resultsNotifier,
          builder: (context, results, _) {
            if (results.isEmpty) {
              return Center(
                child: Text(
                  'Tap a word to see its translation',
                  style: TextStyle(color: colorScheme.outline),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  title: Text(
                    item.lat,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item.eng,
                    style: TextStyle(color: colorScheme.secondary),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
