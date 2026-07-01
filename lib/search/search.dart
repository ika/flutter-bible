// dart
import 'package:bible/bloc/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collections/bible.dart';
import '../collections/search.dart';
import '../bloc/chapter.dart';
import '../bloc/book.dart';
import '../database.dart';
import '../langs/books.dart';
import '../bloc/verse.dart';
import '../versions/bottom.dart';
import '../globals.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Search> _results = [];
  bool _searching = false;
  int _searchRequestId = 0;
  //late String bibleVersion;

  String _selectedCategory = 'All';

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
    fetchLastSearch().then((results) {
      setState(() {
        _results = results;
      });
    });
  }

  Future<List<Search>> fetchLastSearch() {
    return isar.searchs.where().findAll();
  }

  Future<void> saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearchQuery', query);
  }

  Future<String> getSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastSearchQuery') ?? '';
  }

  Future<String> checkSearchQuery(String query) async {
    if (query.isEmpty) {
      return await getSearchQuery();
    }
    return query;
  }

  bool _isAsciiAlphaNum(String char) {
    final codeUnit = char.codeUnitAt(0);
    final isUpper = codeUnit >= 65 && codeUnit <= 90;
    final isLower = codeUnit >= 97 && codeUnit <= 122;
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    return isUpper || isLower || isDigit;
  }

  bool _isBoundaryBeforeIndex(String text, int index) {
    if (index == 0) return true;

    final prevIndex = index - 1;
    final prevChar = text[prevIndex];

    // Normal letters/digits continue the same word.
    if (_isAsciiAlphaNum(prevChar)) {
      return false;
    }

    // Apostrophes and hyphens inside a token are treated as joiners.
    if ((prevChar == "'" || prevChar == '-') && prevIndex > 0 && _isAsciiAlphaNum(text[prevIndex - 1]) && _isAsciiAlphaNum(text[index])) {
      return false;
    }

    return true;
  }

  bool _hasWordPrefixMatch(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int startIndex = 0;
    while (true) {
      final matchIndex = lowerText.indexOf(lowerQuery, startIndex);
      if (matchIndex == -1) return false;

      if (_isBoundaryBeforeIndex(lowerText, matchIndex)) {
        return true;
      }

      startIndex = matchIndex + 1;
    }
  }

  Future<void> _performSearch() async {
    final originalQuery = _searchController.text.trim();
    final requestId = ++_searchRequestId;

    if (originalQuery.isEmpty) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchQuery = '';
        _results = [];
        _searching = false;
      });
      return;
    }

    // save search query to history
    saveSearchQuery(originalQuery);

    setState(() {
      _searching = true;
      _results = [];
    });

    final version = Globals.bibleVersion; //context.read<VersionBloc>().state;
    final bookIds = _categories[_selectedCategory] ?? _categories['All']!;
    List<Search> results = [];

    try {
      final candidateResults = await isar.bibles
          .filter()
          .versionEqualTo(version)
          .anyOf(bookIds, (q, int id) => q.bookEqualTo(id))
          .and()
          .textContains(originalQuery, caseSensitive: false)
          .findAll();

      final filtered = candidateResults.where((verse) => _hasWordPrefixMatch(verse.text, originalQuery)).toList();

      await isar.writeTxn(() async {
        await isar.searchs.clear();
        final searchEntries = filtered.map((verse) {
          return Search()
            ..version = verse.version
            ..book = verse.book
            ..chapter = verse.chapter
            ..verse = verse.verse
            ..text = verse.text;
        }).toList();
        await isar.searchs.putAll(searchEntries);
      });

      results = await isar.searchs.where().findAll();
    } catch (e) {
      debugPrint('Search error: $e');
    }

    if (mounted && requestId == _searchRequestId) {
      setState(() {
        _results = results;
        _searchQuery = originalQuery;
        _searching = false;
      });
    }
  }

  void _clearSearchResults() {
    saveSearchQuery('');
    isar.writeTxn(() async {
      await isar.searchs.clear();
    });
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _results = [];
    });
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final mq = MediaQuery.of(context);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        const tileContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        const leadingSize = 50.0;
        final cats = _categories.keys.toList();

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cats.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: ListTile(
                            contentPadding: tileContentPadding,
                            leading: Container(
                              width: leadingSize,
                              height: leadingSize,
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  cat.isNotEmpty ? cat[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(cat),
                            subtitle: Text('${_categories[cat]?.length ?? 0} books'),
                            selected: isSelected,
                            trailing: isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                              Navigator.pop(context);
                              if (_searchController.text.isNotEmpty) {
                                _performSearch();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _highlightText(String text, String query, BuildContext context) {
    return FutureBuilder<String>(
      future: checkSearchQuery(query),
      builder: (context, snapshot) {
        final String resolvedQuery = snapshot.data ?? query;
        return _buildHighlightedRichText(text, resolvedQuery, context);
      },
    );
  }

  RichText _buildHighlightedRichText(String text, String query, BuildContext context) {
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

    while ((indexOfHighlight = lowercaseText.indexOf(lowercaseQuery, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }

      spans.add(
        TextSpan(
          text: text.substring(indexOfHighlight, indexOfHighlight + query.length),
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
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        leading: GestureDetector(
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Future.delayed(Duration(milliseconds: Globals.navigatorDelay), () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            },
          ),
        ),
        title: FilledButton(
          child: Text(Globals.bibleVersion.toUpperCase()),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => VersionsBottomSheet(
                activeVersion: Globals.bibleVersion,
                onVersionReturnSuccess: ({required String bibleVersion}) {
                  setState(() {
                    context.read<VersionBloc>().add(UpdateVersion(bibleVersion: bibleVersion));
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: colorScheme.primary),
            onPressed: _clearSearchResults,
            tooltip: 'Clear Search',
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: colorScheme.primary),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
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
                      final bookName = BibleBooks.getBookNameByNumber(bible.book);
                      return ListTile(
                        title: Text('$bookName ${bible.chapter}:${bible.verse}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: _highlightText(bible.text, _searchQuery, context),
                        onTap: () {
                          // Navigate to the specific verse
                          context.read<BookNumberBloc>().add(UpdateBook(bibleBookNumber: bible.book));
                          context.read<ChapterBloc>().add(UpdateChapter(chapterNumber: bible.chapter - 1));
                          context.read<VerseBloc>().add(UpdateVerse(verseNumber: bible.verse));
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
