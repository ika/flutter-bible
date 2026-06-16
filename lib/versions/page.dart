import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../collections/booklist.dart';
import '../bloc/version.dart';
import '../database.dart';

class VersionsPage extends StatefulWidget {
  const VersionsPage({super.key});

  @override
  VersionsPageState createState() => VersionsPageState();
}

class VersionsPageState extends State<VersionsPage> {
  List<BookList> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final activeVersion = context.read<VersionBloc>().state;
      final allItems = await isar.bookLists.where().findAll();

      if (!mounted) return;
      setState(() {
        _items = allItems.where((item) => item.abbr != activeVersion).toList();
      });
    } catch (e) {
      debugPrint('Failed to load book lists: $e');
      if (mounted) {
        setState(() {
          _items = [];
          // _filteredItems = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleActive(int index, bool value) async {
    final original = _items[index].active;

    // Optimistic update
    setState(() {
      _items[index].active = value;
    });

    debugPrint(
      'Updating book list: ${_items[index].name} ${_items[index].active}',
    );

    try {
      await isar.writeTxn(() async {
        await isar.bookLists.put(_items[index]);
      });
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _items[index].active = original;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update entry: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Versions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: _refresh,
        //     tooltip: 'Reload',
        //   ),
        // ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${item.abbr.toUpperCase()} · ${item.language.toUpperCase()}',
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      secondary: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            item.abbr.isNotEmpty
                                ? item.abbr[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      value: item.active,
                      onChanged: (v) => _toggleActive(index, v),
                      activeTrackColor: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Bible versions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
