part of 'page.dart';

class MainSelector extends StatefulWidget {
  const MainSelector({super.key});

  @override
  State<MainSelector> createState() => MainSelectorState();
}

class MainSelectorState extends State<MainSelector>
    with SingleTickerProviderStateMixin {
  late String bookName;

  late Map<int, String> allBooks;

  //late Map<int, String> filteredBooks;

  static const double gridMarginSpacing = 16.0;
  static const double gridSpacing = 6.0;
  static const int gridLineCount = 4;

  static const String oldTestamentKey = 'OT';
  static const String newTestamentKey = 'NT';

  late String initialNameState;
  late int initialBookNumber;
  late int initialChapterState;
  late int initialVerseState;
  late String bibleVersion;

  @override
  void initState() {
    super.initState();

    // bookName = BookLists(
    //   useAbbreviations: false,
    // ).readBookName(Globals.bibleBookNumber, Globals.bibleVersion);

    // Set the initial states
    // context.read<BookNameBloc>().add(UpdateBookName(bibleBookName: bookName));
    // context.read<ChapterBloc>().add(UpdateChapter(chapterNumber: 1));
    // context.read<VerseBloc>().add(UpdateVerse(verseNumber: 1));

    // RESTORE INITIAL SETTING IF NOTHING IS SELECTED.
    bibleVersion = context.read<VersionBloc>().state;
    initialNameState = context.read<BookNameBloc>().state;
    initialBookNumber = context.read<BookNumberBloc>().state;
    initialChapterState = context.read<ChapterBloc>().state;
    initialVerseState = context.read<VerseBloc>().state;

    // context.read<ChapterBloc>().add(UpdateChapter(chapterNumber: 1));
    // context.read<VerseBloc>().add(UpdateVerse(verseNumber: 1));

    allBooks = BibleBooks.getAllBookNames();
  }

  void selectNewTestament() {
    setState(() {
      allBooks = BibleBooks.getNewTestamentNames();
    });
  }

  void selectOldTestament() {
    setState(() {
      allBooks = BibleBooks.getOldTestamentNames();
    });
  }

  void searchFilter(String value) {
    setState(() {
      allBooks = BibleBooks.searchBooks(value);
    });
  }

  // --- VERSE SELECTOR ---
  // void showVersesPopup(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Center(child: Text('Verses')),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         height: 400,
  //         child: BlocBuilder<SelectorCountBloc, int>(
  //           builder: (context, count) => GridView.builder(
  //             padding: EdgeInsets.all(gridMarginSpacing),
  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: gridLineCount,
  //               crossAxisSpacing: gridSpacing,
  //               mainAxisSpacing: gridSpacing,
  //             ),
  //             itemCount: count,
  //             itemBuilder: (context, i) => buildSquare('${i + 1}', () {
  //               FocusScope.of(context).unfocus();
  //               final verse = i + 1;
  //               context.read<VerseBloc>().add(UpdateVerse(verseNumber: verse));
  //
  //               // Pop all the way back to the main page
  //               //Navigator.of(context).popUntil((route) => route.isFirst);
  //
  //               // Trigger a scroll to the specific verse
  //               context.read<ScrollBloc>().add(UpdateScroll(index: verse));
  //               Navigator.pop(context);
  //             }),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void showVersesPopup(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) => SafeArea(
  //       child: SizedBox(
  //         height: 500,
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 8),
  //             Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.black26,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Expanded(
  //               child: BlocBuilder<SelectorCountBloc, int>(
  //                 builder: (context, count) {
  //                   if (count <= 0) {
  //                     return Center(
  //                       child: Text(
  //                         'No verses',
  //                         style: TextStyle(
  //                           color: Theme.of(context).colorScheme.onSurface,
  //                         ),
  //                       ),
  //                     );
  //                   }
  //                   return GridView.builder(
  //                     padding: EdgeInsets.all(gridMarginSpacing),
  //                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                       crossAxisCount: gridLineCount,
  //                       crossAxisSpacing: gridSpacing,
  //                       mainAxisSpacing: gridSpacing,
  //                     ),
  //                     itemCount: count,
  //                     itemBuilder: (context, i) => buildSquare('${i + 1}', () {
  //                       FocusScope.of(context).unfocus();
  //                       final verse = i + 1;
  //                       context.read<VerseBloc>().add(UpdateVerse(verseNumber: verse));
  //                       context.read<ScrollBloc>().add(UpdateScroll(index: verse));
  //                       Navigator.pop(context);
  //                     }),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void showVersesPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<SelectorCountBloc, int>(
                  builder: (context, count) {
                    if (count <= 0) {
                      return Center(
                        child: Text(
                          'No chapters',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: count,
                      separatorBuilder: (_, _) => Divider(height: 1),
                      itemBuilder: (context, i) {
                        final chapterNumber = i + 1;
                        return ListTile(
                          title: Text('Verse $chapterNumber'),
                          onTap: () {
                            // FocusScope.of(context).unfocus();
                            // Update chapter (stored as zero-based in your blocs)
                            context.read<VerseBloc>().add(
                              UpdateVerse(verseNumber: i + 1),
                            );
                            // context.read<ScrollBloc>().add(
                            //   UpdateScroll(index: i +1 ),
                            // );
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CHAPTER SELECTOR ---
  // void showChaptersPopup(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Center(child: Text('Chapters')),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         height: 400,
  //         child: BlocBuilder<SelectorCountBloc, int>(
  //           builder: (context, count) => GridView.builder(
  //             padding: EdgeInsets.all(gridMarginSpacing),
  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: gridLineCount,
  //               crossAxisSpacing: gridSpacing,
  //               mainAxisSpacing: gridSpacing,
  //             ),
  //             itemCount: count,
  //             itemBuilder: (context, i) => buildSquare('${i + 1}', () {
  //               FocusScope.of(context).unfocus();
  //               final chapterIndex = i;
  //               final chapterNumber = chapterIndex + 1;
  //
  //               context.read<ChapterBloc>().add(
  //                 UpdateChapter(chapterNumber: chapterIndex),
  //               );
  //
  //               fetchVerseCount(
  //                 version: bibleVersion,
  //                 book: context.read<BookNumberBloc>().state,
  //                 chapter: chapterNumber,
  //               ).then((verseCount) {
  //                 if (context.mounted) {
  //                   context.read<SelectorCountBloc>().add(
  //                     UpdateSelectorCount(selectorCount: verseCount),
  //                   );
  //                   Navigator.pop(context);
  //                   showVersesPopup(context);
  //                 }
  //               });
  //             }),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void showChaptersPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<SelectorCountBloc, int>(
                  builder: (context, count) {
                    if (count <= 0) {
                      return Center(
                        child: Text(
                          'No chapters',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: count,
                      separatorBuilder: (_, _) => Divider(height: 1),
                      itemBuilder: (context, i) {
                        final chapterNumber = i + 1;
                        return ListTile(
                          title: Text('Chapter $chapterNumber'),
                          onTap: () {
                            //FocusScope.of(context).unfocus();
                            // Update chapter (stored as zero-based in your blocs)
                            context.read<ChapterBloc>().add(
                              UpdateChapter(chapterNumber: i),
                            );
                            // Fetch verse count for this chapter, update selector, then show verses
                            fetchVerseCount(
                              version: bibleVersion,
                              book: context.read<BookNumberBloc>().state,
                              chapter: chapterNumber,
                            ).then((verseCount) {
                              if (context.mounted) {
                                context.read<SelectorCountBloc>().add(
                                  UpdateSelectorCount(
                                    selectorCount: verseCount,
                                  ),
                                );

                                Navigator.pop(context); // close bottom sheet
                                showVersesPopup(context); // open verses popup
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BOOK SELECTOR ---
  Widget booksWidget() {
    return Padding(
      padding: const EdgeInsets.all(gridMarginSpacing),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => selectOldTestament(),
                child: const Text('Old Testament'),
              ),
              ElevatedButton(
                onPressed: () => selectNewTestament(),
                child: const Text('New Testament'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: searchFilter,
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Search versions...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: allBooks.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final key = allBooks.keys.elementAt(index);
                final name = allBooks[key]!;
                return ListTile(
                  title: Text(name),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    context.read<BookNameBloc>().add(
                      UpdateBookName(bibleBookName: name),
                    );
                    context.read<BookNumberBloc>().add(
                      UpdateBook(bibleBookNumber: key),
                    );

                    context.read<ChapterBloc>().add(
                      UpdateChapter(chapterNumber: 0),
                    );
                    context.read<VerseBloc>().add(UpdateVerse(verseNumber: 1));

                    fetchChapterCount(version: bibleVersion, book: key).then((
                      chapterCount,
                    ) {
                      if (context.mounted) {
                        context.read<SelectorCountBloc>().add(
                          UpdateSelectorCount(selectorCount: chapterCount),
                        );
                        showChaptersPopup(context);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              context.read<BookNameBloc>().add(
                UpdateBookName(bibleBookName: initialNameState),
              );
              context.read<BookNumberBloc>().add(
                UpdateBook(bibleBookNumber: initialBookNumber),
              );
              context.read<ChapterBloc>().add(
                UpdateChapter(chapterNumber: initialChapterState),
              );
              context.read<VerseBloc>().add(
                UpdateVerse(verseNumber: initialVerseState),
              );

              context.read<ScrollBloc>().add(
                UpdateScroll(index: initialVerseState),
              );

              Navigator.pushNamed(context, '/main');
            },
          ),
          title: BlocBuilder<BookNameBloc, String>(
            builder: (context, nameState) {
              return BlocBuilder<ChapterBloc, int>(
                builder: (context, chapterState) {
                  return BlocBuilder<VerseBloc, int>(
                    builder: (context, verseState) {
                      return TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          // FINAL VALUESI
                          // String nameState = context.read<BookNameBloc>().state;
                          // int bookNumber = context.read<BookBloc>().state;
                          int chapterState = context.read<ChapterBloc>().state;
                          int verseState = context.read<VerseBloc>().state;

                          // debugPrint(
                          //   'Name: $nameState, BookNumber: $bookNumber, Chapter: $chapterState, Verse: $verseState',
                          // );

                          context.read<ChapterBloc>().add(
                            UpdateChapter(chapterNumber: chapterState),
                          );
                          context.read<ScrollBloc>().add(
                            UpdateScroll(index: verseState),
                          );

                          Navigator.pushNamed(context, '/main');
                        },
                        child: Text(
                          '$nameState ${correctChapterDisplay(chapterState)}:$verseState',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        body: booksWidget(),
      ),
    );
  }

  int correctChapterDisplay(int chapterState) {
    return chapterState + 1;
  }

  Widget buildSquare(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black26),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // --- CHAPTER COUNT ---
  Future<int> fetchChapterCount({
    required String version,
    required int book,
  }) async {
    try {
      final chapters = await isar.bibles
          .filter()
          .versionEqualTo(version)
          .bookEqualTo(book)
          .chapterProperty()
          .findAll();

      return chapters.toSet().length;
    } catch (e) {
      debugPrint('Error fetching chapter count: $e');
      return 0;
    }
  }

  // --- VERSE COUNT ---
  Future<int> fetchVerseCount({
    required String version,
    required int book,
    required int chapter,
  }) async {
    try {
      return await isar.bibles
          .filter()
          .versionEqualTo(version)
          .bookEqualTo(book)
          .chapterEqualTo(chapter)
          .count();
    } catch (e) {
      debugPrint('Error fetching verse count: $e');
      return 0;
    }
  }
}
