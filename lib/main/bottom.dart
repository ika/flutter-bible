part of 'page.dart';

final translator = TranslationService();

Future<String> translateText(String input) async {
  final response = await translator.translateLatinToEnglish(input);
  //debugPrint(response);
  return response.isNotEmpty ? response : 'Response returned empty';
}

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key, required this.bibleModel});

  final Bible bibleModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    //debugPrint("language ${Globals.bibleVersionLanguage}");

    //debugPrint('Bible model: id=${model.id}, book=${model.book}, chapter=${model.chapter}, verse=${model.verse}, version=${model.version}, text=${model.text}');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // Container(
          //   width: 40,
          //   height: 4,
          //   margin: const EdgeInsets.only(bottom: 16),
          //   decoration: BoxDecoration(
          //     color: theme.dividerColor,
          //     borderRadius: BorderRadius.circular(2),
          //   ),
          // ),
          const SizedBox(height: 8),
          Text(
            "${bibleModel.version.toUpperCase()} - ${BibleBooks.getBookAbbrByNumber(bibleModel.book)} ${bibleModel.chapter}:${bibleModel.verse}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          //(Globals.bibleVersionLanguage == 'lat')
              //? GestureDetector(
                  // onTap: () {
                  //   Navigator.pop(context);
                  //   showModalBottomSheet(
                  //     context: context,
                  //     isScrollControlled: true,
                  //     shape: const RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.vertical(
                  //         top: Radius.circular(20),
                  //       ),
                  //     ),
                  //     builder: (context) =>
                  //         DictionaryWidget(bibleModel: bibleModel),
                  //   );
                  // },
                //   child: Text(
                //     bibleModel.text,
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontSize: 14,
                //       color: colorScheme.onSurfaceVariant,
                //     ),
                //   ),
                // )
              Text(
                  bibleModel.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              //leading: Icon(Icons.compare, color: colorScheme.onPrimaryContainer),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              title: const Text('Compare Verse'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) =>
                      CompareVersesSheet(bibleModel: bibleModel),
                );
              },
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
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
                        UpdateVerse(verseNumber: bibleModel.verse),
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
          ),
          //const Divider(height: 1),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              //leading: Icon(Icons.compare, color: colorScheme.onPrimaryContainer),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
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
                        UpdateVerse(verseNumber: bibleModel.verse),
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
          ),
          //const Divider(height: 1),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              //leading: Icon(Icons.compare, color: colorScheme.onPrimaryContainer),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'T',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              title: const Text('Translate Verse'),
              onTap: () {
                Navigator.pop(context);
                final String verseText = bibleModel.text;
                showDialog(
                  context: context,
                  builder: (dialogContext) => TranslationDialog(
                    verseText: verseText,
                    reference:
                    '${BibleBooks.getBookNameByNumber(bibleModel.book)} ${bibleModel.chapter}:${bibleModel.verse}',
                  ),

                );
              },
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
              //leading: Icon(Icons.compare, color: colorScheme.onPrimaryContainer),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              title: const Text('Copy Verse'),
              onTap: () {
                Navigator.pop(context);
                final fullText =
                    '${bibleModel.text} ${BibleBooks.getBookNameByNumber(bibleModel.book)} ${bibleModel.chapter}:${bibleModel.verse}';
                Clipboard.setData(ClipboardData(text: fullText));
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Text copied')),
                );
              },
            ),
          ),
          //const Divider(height: 1),
        ],
      ),
    );
  }

  Future<int?> _getExistingCacheId(int code) async {
    return await isar.caches
        .filter()
        .versionEqualTo(bibleModel.version)
        .bookEqualTo(bibleModel.book)
        .chapterEqualTo(bibleModel.chapter)
        .verseEqualTo(bibleModel.verse)
        .codeEqualTo(code)
        .idProperty()
        .findFirst();
  }

  Future<void> _addCacheEntry(int code) async {
    final entry = Cache()
      ..id = bibleModel.id
      ..version = bibleModel.version
      ..book = bibleModel.book
      ..chapter = bibleModel.chapter
      ..verse = bibleModel.verse
      ..text = bibleModel.text
      ..code = code;
    await isar.writeTxn(() => isar.caches.put(entry));
  }
}

class TranslationDialog extends StatefulWidget {
  const TranslationDialog({
    super.key,
    required this.verseText,
    required this.reference,
  });

  final String verseText;
  final String reference;

  @override
  State<TranslationDialog> createState() => _TranslationDialogState();
}

class _TranslationDialogState extends State<TranslationDialog> {
  late Future<String> _translationFuture;

  @override
  void initState() {
    super.initState();
    _translationFuture = translateText(widget.verseText);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.translate, color: colorScheme.primary),
      title: Text(
        widget.reference,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original (Latin):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.verseText,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Translation (English):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _translationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: colorScheme.error),
                    );
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data ?? 'No translation',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  } else {
                    return Text(
                      'No translation available',
                      style: TextStyle(color: colorScheme.outline),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            final fullText = '${widget.verseText} (${widget.reference})';
            Clipboard.setData(ClipboardData(text: fullText));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Translation copied')));
          },
          child: const Text('Copy'),
        ),
      ],
    );
  }
}
