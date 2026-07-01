import 'package:flutter/material.dart';
import '../collections/booklist.dart';
import '../database.dart';
import '../globals.dart';
import '../constants.dart';

class VersionsBottomSheet extends StatelessWidget {
  const VersionsBottomSheet({
    super.key,
    required this.activeVersion,
    required this.onVersionReturnSuccess,
  });

  final String activeVersion;
  final void Function({required String bibleVersion}) onVersionReturnSuccess;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const tileContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const leadingSize = 50.0;
    activeVersion.toLowerCase();

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
                    return Column(
                      children: items.map((entry) {
                        final key = entry.abbr.toLowerCase();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                      entry.abbr.isNotEmpty
                                          ? entry.abbr[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
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
                                  final lang = Constants.bibleVersions[key]?['lang'] ?? 'en';
                                  Globals.bibleVersionLanguage = lang;
                                  Globals.bibleVersion = key;
                                  onVersionReturnSuccess(bibleVersion: key);
                                },
                              ),
                            ),
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
