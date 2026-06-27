part of 'page.dart';

class CompareVersesSheet extends StatelessWidget {
  const CompareVersesSheet({super.key, required this.bibleModel});

  final Bible bibleModel;

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
          .bookEqualTo(bibleModel.book)
          .chapterEqualTo(bibleModel.chapter)
          .verseEqualTo(bibleModel.verse)
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            "${bibleModel.version.toUpperCase()} - ${BibleBooks.getBookAbbrByNumber(bibleModel.book)} ${bibleModel.chapter}:${bibleModel.verse}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          //(Globals.bibleVersionLanguage == 'lat')
          //     ? GestureDetector(
          //         onTap: () {
          //           Navigator.pop(context);
          //           showModalBottomSheet(
          //             context: context,
          //             isScrollControlled: true,
          //             shape: const RoundedRectangleBorder(
          //               borderRadius: BorderRadius.vertical(
          //                 top: Radius.circular(20),
          //               ),
          //             ),
          //             builder: (context) =>
          //                 DictionaryWidget(bibleModel: bibleModel),
          //           );
          //         },
          //         child: Text(
          //           bibleModel.text,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: colorScheme.onSurfaceVariant,
          //           ),
          //         ),
          //       )
          Text(
            bibleModel.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
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
                    //final abbr = (item['version'] as String).toUpperCase();
                    //final letter = abbr.isNotEmpty ? abbr[0] : '?';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
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
                          // leading: Padding(
                          //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                          //   child: Container(
                          //     width: 44,
                          //     height: 44,
                          //     decoration: BoxDecoration(
                          //       color: colorScheme.primaryContainer,
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     child: Center(
                          //       child: Text(
                          //         letter,
                          //         style: TextStyle(
                          //           color: colorScheme.onPrimaryContainer,
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 18,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // gap benieth the list of versions
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
