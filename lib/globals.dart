import 'package:flutter/foundation.dart';

class Globals {
  // static final refreshNotifier = ChangeNotifier();

  // Use a private instance with a public getter if you want to be strict,
  // but a simple static final works for this purpose.
  static final refreshNotifier = RefreshNotifier();

  static int navigatorDelay = 200;
  static int navigatorLongDelay = 400;
  static int navigatorDialogDelay = 2500;
  static int cacheSelector = 1; // 1 = bookmarks 2 = Highlights

  static List bookMarkList = [];
  static List highLightList = [];

  // Bible version number
  static int bibleVersion = 0;

  // Start with Gospel of John
  static int bibleBookNumber = 43;

  // Book name
  static String bibleBookName = 'John';

  // Bible language eng or lat
  static String bibleVersionLanguage = 'eng';

  static String appVersion = '1.1.0';
}

// Create a small subclass to expose the notify method
class RefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
