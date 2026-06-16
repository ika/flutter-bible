part of 'page.dart';

class BottomSheetCacheWidget extends StatelessWidget {
  const BottomSheetCacheWidget({super.key, required this.model, required this.onCacheReturnSuccess});

  final Cache model;
  final VoidCallback onCacheReturnSuccess;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return SafeArea(
      top: false, // keep top area if you prefer
      child: Container(
        // Limit height so the sheet won't overflow the screen
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
        // Add background & shape consistent with modal sheet
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Ensure content is scrollable and padded for keyboard
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // important to avoid unbounded height
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
                  ),
                ),

                // Example body - replace with your actual content widgets
                Text(model.text),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.chevron_right),
                  title: const Text('Go To Verse'),
                  onTap: () async {
                    Navigator.pop(context);

                    context.read<VersionBloc>().add(UpdateVersion(bibleVersion: model.version));

                    context.read<BookNumberBloc>().add(UpdateBook(bibleBookNumber: model.book));

                    context.read<ChapterBloc>().add(UpdateChapter(chapterNumber: model.chapter - 1));

                    context.read<VerseBloc>().add(UpdateVerse(verseNumber: model.verse));

                    Navigator.pushNamed(context, '/main');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete Entry'),
                  onTap: () async {
                    Navigator.pop(context);
                    final bool? confirm = await confirmDialog(context, 'Delete this Entry?');
                    // Use "confirm ?? false" to safely handle null (clicking outside)
                    if (confirm ?? false) {
                      await isar.writeTxn(() => isar.caches.delete(model.id));
                      onCacheReturnSuccess();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry Deleted!')));
                      }
                    }
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> confirmDialog(BuildContext context, String title) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          // This centers the title
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        // This centers the buttons
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
