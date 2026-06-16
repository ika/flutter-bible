import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/verse.dart';
import '../bloc/version.dart';
import '../bloc/book.dart';
import '../bloc/chapter.dart';
import '../collections/cache.dart';
import '../globals.dart';
import '../database.dart';
import '../langs/books.dart';

part 'bottom.dart';

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  CachePageState createState() => CachePageState();
}

class CachePageState extends State<CachePage> {
  List<Cache> list = List<Cache>.empty();
  late Future<List<Cache>> _cacheFuture;

  String titleText = (Globals.cacheSelector == 1) ? 'Bookmarks' : 'Highlights';

  @override
  void initState() {
    super.initState();
    _cacheFuture = getCacheFuture();
  }

  Future<List<Cache>> getCacheFuture() {
    return isar.caches
        .filter()
        .codeEqualTo(Globals.cacheSelector)
        .sortByTimestampDesc() // This will definitely be generated
        .findAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cache>>(
      future: _cacheFuture,
      builder: (context, AsyncSnapshot<List<Cache>> snapshot) {
        if (snapshot.hasData) {
          list = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              backgroundColor: Colors.transparent,
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
              leading: GestureDetector(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Future.delayed(
                      Duration(milliseconds: Globals.navigatorDelay),
                      () {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
              title: Text(
                titleText,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final bool? confirm = await confirmDialog(
                      context,
                      'Delete All Entries?',
                    );

                    if (confirm ?? false) {
                      // Perform the deletion in a write transaction
                      await isar.writeTxn(() async {
                        await isar.caches
                            .filter()
                            .codeEqualTo(Globals.cacheSelector)
                            .deleteAll();
                      });

                      // Update UI after the database operation is finished
                      setState(() {
                        _cacheFuture = getCacheFuture();
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All entries deleted!')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.separated(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  String bookName = BibleBooks.getBookNameByNumber(
                    list[index].book,
                  );
                  return ListTile(
                    title: Text(
                      '${list[index].version.toUpperCase()} - $bookName ${list[index].chapter}:${list[index].verse}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.linear_scale,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            list[index].text,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    onTap: () {
                      final model = Cache()
                        ..id = list[index].id
                        ..version = list[index].version
                        ..book = list[index].book
                        ..chapter = list[index].chapter
                        ..verse = list[index].verse
                        ..text = list[index].text
                        ..code = list[index].code;

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext bottomSheetContext) {
                          return BottomSheetCacheWidget(
                            model: model,
                            onCacheReturnSuccess: () {
                              setState(() {
                                _cacheFuture = getCacheFuture();
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
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
          child: const Text(
            'Yes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'No',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
