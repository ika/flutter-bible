import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../bloc/font.dart';
import '../bloc/italic.dart';
import '../bloc/size.dart';
import '../bloc/theme.dart';
import '../search/search.dart';
import '../theme/apptheme.dart';
import '../theme/theme.dart';
import '../collections/bible.dart';
import '../collections/booklist.dart';
import '../collections/cache.dart';
import '../bloc/book.dart';
import '../bloc/bookname.dart';
import '../bloc/chapter.dart';
import '../bloc/scroll.dart';
import '../bloc/selectorcount.dart';
import '../bloc/verse.dart';
import '../bloc/version.dart';
import '../versions/page.dart';
import '../cache/page.dart';
import '../collections/search.dart';
import '../fonts/fonts.dart';
import '../backup/screen.dart';
import './constants.dart';
import './database.dart';
import './main/page.dart';

//-------------------------------------------
// Entry point: initialize bindings, platform DB factory, storage and Isar,
// load Bible versions, book list and words, then run the app.
//-------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Use applicationSupportDirectory instead of Documents for better platform compatibility
  final Directory dir = await getApplicationSupportDirectory();

  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(dir.path),
  );

  isar = await Isar.open(
    [BibleSchema, CacheSchema, BookListSchema, SearchSchema],
    name: 'bible_data',
    directory: dir.path,
  );

  for (var entry in Constants.bibleVersions.entries) {
    await ensureVersionLoaded(entry.key);
  }

  //-------------------------------------------
  // Check if book list is loaded, if not load it
  //-------------------------------------------
  await ensureBookListLoaded();

  //-------------------------------------------
  // Check if words are loaded, if not load them
  //-------------------------------------------

  runApp(const RunApp());
}

//-------------------------------------------
// Root widget: provides Blocs and configures MaterialApp (routes, theme).
//-------------------------------------------
class RunApp extends StatelessWidget {
  const RunApp({super.key});

  //-------------------------------------------
  // Returns a list of BlocProviders used by the application.
  //-------------------------------------------
  List<BlocProvider> get _providers => [
    BlocProvider<VersionBloc>(create: (_) => VersionBloc()),
    BlocProvider<BookNumberBloc>(create: (_) => BookNumberBloc()),
    BlocProvider<ChapterBloc>(create: (_) => ChapterBloc()),
    BlocProvider<VerseBloc>(create: (_) => VerseBloc()),
    BlocProvider<BookNameBloc>(create: (_) => BookNameBloc()),
    BlocProvider<FontBloc>(create: (_) => FontBloc()),
    BlocProvider<ItalicBloc>(create: (_) => ItalicBloc()),
    BlocProvider<SizeBloc>(create: (_) => SizeBloc()),
    BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
    BlocProvider<ScrollBloc>(create: (_) => ScrollBloc()),
    BlocProvider<SelectorCountBloc>(create: (_) => SelectorCountBloc()),
  ];

  //-------------------------------------------
  // Builds the widget tree: MultiBlocProvider with MaterialApp and routes.
  //-------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _providers,
      child: BlocBuilder<ThemeBloc, int>(
        builder: (context, state) {
          return MaterialApp(
            locale: const Locale('en'),
            debugShowCheckedModeBanner: false,
            title: Constants.projectName,
            theme: selectTheme(state),
            initialRoute: '/main',
            routes: {
              '/main': (context) => const MainPage(),
              '/cache': (context) => const CachePage(),
              '/fonts': (context) => const FontsPage(),
              '/themes': (context) => const ThemePage(),
              '/versions': (context) => const VersionsPage(),
              '/search': (context) => const SearchPage(),
              '/backup': (context) => const IsarBackupScreen(),
            },
          );
        },
      ),
    );
  }
}

//-------------------------------------------
// Ensure the book list is loaded: checks existing data and inserts defaults
// from Constants.bibleVersions if missing.
//-------------------------------------------
Future<void> ensureBookListLoaded() async {
  final count = await isBookListLoaded();
  if (count > 0) {
    debugPrint('Book list is already loaded.');
    return;
  }

  debugPrint('Loading book list...');

  final entries = Constants.bibleVersions.entries.map((entry) {
    return BookList()
      ..abbr = entry.key
      ..name = entry.value['name']!
      ..language = entry.value['lang']!
      ..number = int.parse(entry.value['number']!)
      ..active = true;
  }).toList();

  if (entries.isEmpty) {
    debugPrint('No bibleVersions found in Constants.');
    return;
  }

  await isar.writeTxn(() async {
    try {
      await isar.bookLists.putAll(entries);
      debugPrint('Inserted ${entries.length} book list entries.');
    } catch (e) {
      debugPrint('Error inserting book lists: $e');
    }
  });
}

//-------------------------------------------
// Returns whether any book list entries exist in Isar.
//-------------------------------------------
Future<int> isBookListLoaded() async {
  final count = await isar.bookLists.count();
  return count;
}

//-------------------------------------------
// Ensure a Bible version is loaded: checks and loads the version if needed.
//-------------------------------------------
Future<void> ensureVersionLoaded(String versionCode) async {
  final alreadyLoaded = await isVersionLoaded(versionCode);

  if (alreadyLoaded) {
    debugPrint('$versionCode is already loaded.');
    return;
  }

  debugPrint('Loading $versionCode...');
  await loadBibleVersion(versionCode);
}

//-------------------------------------------
// Returns whether the specified Bible version has at least the first verse.
//-------------------------------------------
Future<bool> isVersionLoaded(String versionCode) async {
  final count = await isar.bibles
      .filter()
      .versionEqualTo(versionCode)
      .bookEqualTo(1)
      .chapterEqualTo(1)
      .verseEqualTo(1)
      .count();

  return count > 0;
}

//-------------------------------------------
// Load a Bible version from assets (assets/{versionCode}.json) and insert verses.
//-------------------------------------------
Future<void> loadBibleVersion(String versionCode) async {
  final path = 'assets/$versionCode.json';
  final jsonString = await rootBundle.loadString(path);
  final List<dynamic> data = jsonDecode(jsonString);

  final verses = data.map((item) {
    return Bible()
      ..version = versionCode
      ..book = item['b']
      ..chapter = item['c']
      ..verse = item['v']
      ..text = item['t'];
  }).toList();

  await isar.writeTxn(() async {
    try {
      await isar.bibles.putAll(verses);
    } catch (e) {
      debugPrint('Error inserting verses: $e');
    }
  });
}

//-------------------------------------------
// Clear Select Isar collections.
//-------------------------------------------
Future<void> clearAllData() async {
  await isar.writeTxn(() async {
    debugPrint('All Isar collections have been cleared.');
  });
}
