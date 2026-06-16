
part of 'page.dart';

//-------------------------------------------------------------
// Chapter Page
//-------------------------------------------------------------

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key, required this.bibleVersion, required this.bookNumber, required this.chapterIndex});

  final String bibleVersion;
  final int bookNumber;
  final int chapterIndex;

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  late Future<List<Bible>> _chapterFuture;

  @override
  void initState() {
    _chapterFuture = getChapterFuture();
    super.initState();
  }

  // If the user swipes to a new chapter, the widget is updated
  @override
  void didUpdateWidget(ChapterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterIndex != widget.chapterIndex ||
        oldWidget.bookNumber != widget.bookNumber ||
        oldWidget.bibleVersion != widget.bibleVersion) {
      _chapterFuture = getChapterFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScrollBloc, int>(
      listenWhen: (prev, curr) => curr > 0,
      listener: (context, targetVerse) => performScroll(targetVerse),
      child: FutureBuilder<List<Bible>>(
        future: _chapterFuture, // Use the persistent future
        builder: (BuildContext context, AsyncSnapshot<List<Bible>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final chapters = snapshot.data ?? [];

            int verseToScroll = context.read<VerseBloc>().state;
            if (verseToScroll > 0) {
              context.read<ScrollBloc>().add(UpdateScroll(index: verseToScroll));
            }

            return ScrollablePositionedList.builder(
              itemCount: chapters.length,
              itemScrollController: _itemScrollController,
              addSemanticIndexes: true,
              //physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final chapter = chapters[index];
                if (chapter.id == -1) {
                  return const SizedBox(height: 100);
                }
                return ListTile(
                  //tileColor: thisBackgroundColor(context, chapter.id),
                  title: Text(
                    "${chapter.verse}: ${chapter.text}",
                    style: TextStyle(
                      height: 1.2,
                      fontFamily: fontsList[context.read<FontBloc>().state],
                      fontStyle: (context.read<ItalicBloc>().state) ? FontStyle.italic : FontStyle.normal,
                      fontSize: context.read<SizeBloc>().state,
                      backgroundColor: thisBackgroundColor(context, chapter.id),
                    ),
                    // textAlign: TextAlign.center,
                  ),
                  onTap: () => _openBottomSheet(chapter),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _openBottomSheet(Bible chapter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => BottomSheetWidget(model: chapter),
    );
  }

  Future<List<Bible>> getChapterFuture() async {
    // debugPrint('BibleVersion: ${widget.bibleVersion}');
    final List<Bible> realVerses = await isar.bibles
        .filter()
        .versionEqualTo(widget.bibleVersion)
        .bookEqualTo(widget.bookNumber)
        .chapterEqualTo(widget.chapterIndex)
        .sortByVerse()
        .findAll();

    final List<Bible> versesWithPadding = List.from(realVerses);

    for (int i = 0; i < 20; i++) {
      versesWithPadding.add(
        Bible()
          ..id = -1
          ..verse = 0
          ..text = ""
          ..version = ""
          ..book = 0
          ..chapter = 0,
      );
    }
    return versesWithPadding;
  }

  Color? thisTileColor(BuildContext context, int id) {
    if (Globals.bookMarkList.contains(id)) {
      return Theme.of(context).highlightColor.withValues(alpha: 0.4);
    } else if (Globals.highLightList.contains(id)) {
      return Theme.of(context).highlightColor.withValues(alpha: 0.2);
    }
    return null;
  }

  Color? thisBackgroundColor(BuildContext context, int id) {
    if (Globals.bookMarkList.contains(id)) {
      return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4);
    } else if (Globals.highLightList.contains(id)) {
      return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2);
    }
    return null;
  }

  void performScroll(int targetVerse) {
    // Check if targetVerse is 0 to avoid infinite loops
    if (targetVerse <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(index: targetVerse - 1, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
        // Reset the Bloc to 0.
        // Crucial: This ensures that if you swipe away and back,
        // it doesn't jump back to this verse again.
        context.read<ScrollBloc>().add(UpdateScroll(index: 0));
      } else {
        // If not attached yet (still loading), try again in the next frame
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) performScroll(targetVerse);
        });
      }
    });
  }
}
