part of 'page.dart';

class ParallelVersesSheet extends StatelessWidget {
  final String text;
  final int book;
  final int chapter;
  final int verse;

  const ParallelVersesSheet({
    super.key,
    required this.text,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  Future<List<Map<String, dynamic>>> _loadParallelData(
    BuildContext context,
  ) async {
    try {
      // 1. Get the current active version from Bloc
      final currentVersion = context.read<VersionBloc>().state;

      // 2. Get all active versions from BookList, excluding the current one
      final activeBooks = await isar.bookLists
          .filter()
          .activeEqualTo(true)
          .not()
          .abbrEqualTo(currentVersion)
          .findAll();

      if (activeBooks.isEmpty) return [];

      final activeAbbrs = activeBooks.map((b) => b.abbr).toList();
      final nameMap = {for (var b in activeBooks) b.abbr: b.name};

      // 3. Fetch verses for these versions
      final verses = await isar.bibles
          .filter()
          .bookEqualTo(book)
          .chapterEqualTo(chapter)
          .verseEqualTo(verse)
          .anyOf(activeAbbrs, (q, String abbr) => q.versionEqualTo(abbr))
          .findAll();

      // 4. Combine data
      return verses.map((v) {
        return {
          'text': v.text,
          'version': v.version,
          'name': nameMap[v.version] ?? v.version,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error loading parallel verses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            "${BibleBooks.getBookAbbrByNumber(book)} $chapter:$verse",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          // Text(
          //   text,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          // ),
          (Globals.bibleVersionLanguage == 'lat')
              ? GestureDetector(
                  onTap: () {
                    // 1. Close the BottomSheet first
                    Navigator.pop(context);
                    // 2. Open the Dialog as a standalone route
                    showDialog(
                      context: context,
                      builder: (context) => WordSearchWidget(verseText: text),
                    );
                  },
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadParallelData(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      "No other active versions found.",
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['name'].toString().toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['text'],
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
