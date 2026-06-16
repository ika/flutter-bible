// dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../collections/bible.dart';
import '../bloc/version.dart';
import '../bloc/chapter.dart';
import '../bloc/book.dart';
import '../database.dart';
import '../langs/books.dart';
import '../bloc/verse.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Bible> _results = [];
  bool _searching = false;

  String _selectedCategory = 'All';
  late String _version;

  final Map<String, List<int>> _categories = {
    'All': List.generate(66, (i) => i + 1),
    'Pentateuch': [1, 2, 3, 4, 5],
    'Historical': [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    'Poetical': [18, 19, 20, 21, 22],
    'Major Prophets': [23, 24, 25, 26, 27],
    'Minor Prophets': [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39],
    'Gospels': [40, 41, 42, 43],
    'Acts': [44],
    'Pauline Letters': [45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57],
    'General Letters': [58, 59, 60, 61, 62, 63, 64, 65],
    'Revelation': [66],
  };

  @override
  void initState() {
    super.initState();
    _version = context.read<VersionBloc>().state.toUpperCase();
  }

  Future<void> _performSearch() async {
    final originalQuery = _searchController.text.trim();
    if (originalQuery.isEmpty) return;

    setState(() {
      _searching = true;
      _results = [];
    });

    final version = context.read<VersionBloc>().state;
    final bookIds = _categories[_selectedCategory]!;

    String currentQuery = originalQuery;
    List<Bible> results = [];

    while (currentQuery.isNotEmpty) {
      try {
        results = await isar.bibles
            .filter()
            .versionEqualTo(version)
            .anyOf(bookIds, (q, int id) => q.bookEqualTo(id))
            .and()
            .textContains(currentQuery, caseSensitive: false)
            .findAll();

        if (results.isNotEmpty) {
          break;
        }
        currentQuery = currentQuery.substring(0, currentQuery.length - 1);
      } catch (e) {
        debugPrint('Search error: $e');
        break;
      }
    }

    if (mounted) {
      setState(() {
        _results = results;
        _searchQuery = currentQuery;
        _searching = false;
      });
    }
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final cats = _categories.keys.toList();
        final maxHeight = MediaQuery.of(context).size.height * 0.6;

        return SafeArea(
          child: SizedBox(
            height: maxHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // optional drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      final isSelected = _selectedCategory == cat;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest,
                          radius: 18,
                          child: Text(
                            cat.isNotEmpty ? cat[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(cat),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          Navigator.pop(context);
                          if (_searchController.text.isNotEmpty) {
                            _performSearch();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  RichText _highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    final List<TextSpan> spans = [];
    final String lowercaseText = text.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowercaseText.indexOf(lowercaseQuery, start)) !=
        -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }

      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + query.length,
          ),
          style: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );

      start = indexOfHighlight + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Search - $_version',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategorySelector,
            tooltip: 'Select Category',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search input moved below the AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      // subtle tint using the color extension `withValues`
                      fillColor: colorScheme.surface.withValues(alpha: 0.04),
                      // outline border + focused/disabled variants
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: colorScheme.outline, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: colorScheme.outline, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Category: $_selectedCategory',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty && _searchQuery.isNotEmpty
                ? const Center(child: Text('No results found.'))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final bible = _results[index];
                      final bookName = BibleBooks.getBookNameByNumber(
                        bible.book,
                      );
                      return ListTile(
                        title: _highlightText(
                          bible.text,
                          _searchQuery,
                          context,
                        ),
                        subtitle: Text(
                          '$bookName ${bible.chapter}:${bible.verse}',
                          style: TextStyle(color: colorScheme.secondary),
                        ),
                        onTap: () {
                          // Navigate to the specific verse
                          context.read<BookNumberBloc>().add(
                            UpdateBook(bibleBookNumber: bible.book),
                          );
                          context.read<ChapterBloc>().add(
                            UpdateChapter(chapterNumber: bible.chapter - 1),
                          );
                          context.read<VerseBloc>().add(
                            UpdateVerse(verseNumber: bible.verse),
                          );
                          Navigator.pushNamed(context, '/main');
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
