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

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  CachePageState createState() => CachePageState();
}

class CachePageState extends State<CachePage> {
  List<Cache> list = [];
  bool isLoading = true;

  String titleText = (Globals.cacheSelector == 1) ? 'Bookmarks' : 'Highlights';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    list = await getCacheFuture();
    setState(() {
      isLoading = false;
    });
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
        title: Text(titleText, style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            String bookName = BibleBooks.getBookNameByNumber(list[index].book);
            return Dismissible(
              key: Key(list[index].id.toString()),
              direction: DismissDirection.startToEnd,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                final itemId = list[index].id;
                list.removeAt(index);
                setState(() {});
                await isar.writeTxn(() async {
                  await isar.caches.delete(itemId);
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entry deleted')),
                  );
                }
              },
              child: ListTile(
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
                  context.read<VersionBloc>().add(
                    UpdateVersion(bibleVersion: list[index].version),
                  );

                  context.read<BookNumberBloc>().add(
                    UpdateBook(bibleBookNumber: list[index].book),
                  );

                  context.read<ChapterBloc>().add(
                    UpdateChapter(chapterNumber: list[index].chapter - 1),
                  );

                  context.read<VerseBloc>().add(
                    UpdateVerse(verseNumber: list[index].verse),
                  );

                  Navigator.pushNamed(context, '/main');
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ),
    );
  }
}
