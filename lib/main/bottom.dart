part of 'page.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key, required this.bibleModel});

  final Bible bibleModel;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    const tileContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const leadingSize = 50.0;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Verse info section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "${bibleModel.version.toUpperCase()} - ${BibleBooks.getBookAbbrByNumber(bibleModel.book)} ${bibleModel.chapter}:${bibleModel.verse}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bibleModel.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: tileContentPadding,
                    leading: Container(
                      width: leadingSize,
                      height: leadingSize,
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
                    title: Text('Compare Verse'),
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
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: tileContentPadding,
                    leading: Container(
                      width: leadingSize,
                      height: leadingSize,
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
                    title: Text('Bookmark Verse'),
                    onTap: () async {
                      Navigator.pop(context);
                      final existingId = await _getExistingCacheId(1);
                      if (existingId != null) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Already bookmarked'),
                          ),
                        );
                      } else {
                        await _addCacheEntry(1).then((_) {
                          if (context.mounted) {
                            context.read<VerseBloc>().add(
                              UpdateVerse(
                                verseNumber: bibleModel.verse,
                              ),
                            );
                          }
                          Globals.refreshNotifier.refresh();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Bookmark saved'),
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: tileContentPadding,
                    leading: Container(
                      width: leadingSize,
                      height: leadingSize,
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
                    title: Text('Highlight Verse'),
                    onTap: () async {
                      Navigator.pop(context);
                      final existingId = await _getExistingCacheId(2);
                      if (existingId != null) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Already highlighted'),
                          ),
                        );
                      } else {
                        await _addCacheEntry(2).then((_) {
                          if (context.mounted) {
                            context.read<VerseBloc>().add(
                              UpdateVerse(
                                verseNumber: bibleModel.verse,
                              ),
                            );
                          }
                          Globals.refreshNotifier.refresh();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Highlight saved'),
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
                if(Globals.bibleVersionLanguage == 'lat')
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: tileContentPadding,
                    leading: Container(
                      width: leadingSize,
                      height: leadingSize,
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
                    title: Text('Translate Verse'),
                    onTap: () async {
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
                      color: colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: tileContentPadding,
                    leading: Container(
                      width: leadingSize,
                      height: leadingSize,
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
                    title: Text('Copy Verse'),
                    onTap: () async {
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
              ],
            ),
          ),
        ),
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
