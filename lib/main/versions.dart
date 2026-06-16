part of 'page.dart';

class VersionsBottomSheet extends StatelessWidget {
  const VersionsBottomSheet({super.key, required this.activeVersion});

  final String activeVersion;

  Future<List<BookList>> _loadBookLists() async {
    try {
      return await isar.bookLists.filter().activeEqualTo(true).findAll();
    } catch (e) {
      debugPrint('Failed to load book lists: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<BookList>>(
                  future: _loadBookLists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No versions found')),
                      );
                    }
                    return Column(
                      children: items.map((entry) {
                        final key = entry.abbr;
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.translate),
                              title: Text(entry.name),
                              subtitle: Text(
                                '${key.toUpperCase()} - ${entry.language}',
                              ),
                              selected: activeVersion == key,
                              trailing: activeVersion == key
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : null,
                              onTap: () async {
                                debugPrint(
                                  'Saving version: $key ${entry.number} - ${entry.language}',
                                );
                                context.read<VersionBloc>().add(
                                  UpdateVersion(bibleVersion: key),
                                );
                                //Globals.bibleVersionLanguage = entry.language;

                                if (context.mounted) Navigator.pop(context);
                                Navigator.pushNamed(context, '/main');
                              },
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
