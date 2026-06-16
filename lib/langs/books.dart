class BibleBooks {
  // Forward mapping: abbreviation → number (Protestant 1-66)
  static const Map<String, int> bookMappings = {
    // Old Testament
    'GEN': 1,
    'EXO': 2,
    'LEV': 3,
    'NUM': 4,
    'DEU': 5,
    'JOS': 6,
    'JDG': 7,
    'RUT': 8,
    '1SA': 9,
    '2SA': 10,
    '1KI': 11,
    '2KI': 12,
    '1CH': 13,
    '2CH': 14,
    'EZR': 15,
    'NEH': 16,
    'EST': 17,
    'JOB': 18,
    'PSA': 19,
    'PRO': 20,
    'ECC': 21,
    'SNG': 22,
    'ISA': 23,
    'JER': 24,
    'LAM': 25,
    'EZK': 26,
    'DAN': 27,
    'HOS': 28,
    'JOL': 29,
    'AMO': 30,
    'OBA': 31,
    'JON': 32,
    'MIC': 33,
    'NAM': 34,
    'HAB': 35,
    'ZEP': 36,
    'HAG': 37,
    'ZEC': 38,
    'MAL': 39,
    // New Testament
    'MAT': 40,
    'MRK': 41,
    'LUK': 42,
    'JHN': 43,
    'ACT': 44,
    'ROM': 45,
    '1CO': 46,
    '2CO': 47,
    'GAL': 48,
    'EPH': 49,
    'PHP': 50,
    'COL': 51,
    '1TH': 52,
    '2TH': 53,
    '1TI': 54,
    '2TI': 55,
    'TIT': 56,
    'PHM': 57,
    'HEB': 58,
    'JAS': 59,
    '1PE': 60,
    '2PE': 61,
    '1JN': 62,
    '2JN': 63,
    '3JN': 64,
    'JUD': 65,
    'REV': 66,
  };

  // Completed chapter counts for each book of the Bible
  // static const Map<int, int> bookChapterCount = {
  //   1: 50, // Genesis
  //   2: 40, // Exodus
  //   3: 27, // Leviticus
  //   4: 36, // Numbers
  //   5: 34, // Deuteronomy
  //   6: 24, // Joshua
  //   7: 21, // Judges
  //   8: 4, // Ruth
  //   9: 31, // 1 Samuel
  //   10: 24, // 2 Samuel
  //   11: 22, // 1 Kings
  //   12: 25, // 2 Kings
  //   13: 29, // 1 Chronicles
  //   14: 36, // 2 Chronicles
  //   15: 10, // Ezra
  //   16: 13, // Nehemiah
  //   17: 10, // Esther
  //   18: 42, // Job
  //   19: 150, // Psalms
  //   20: 31, // Proverbs
  //   21: 12, // Ecclesiastes
  //   22: 8, // Song of Solomon
  //   23: 66, // Isaiah
  //   24: 52, // Jeremiah
  //   25: 5, // Lamentations
  //   26: 48, // Ezekiel
  //   27: 12, // Daniel
  //   28: 14, // Hosea
  //   29: 3, // Joel
  //   30: 9, // Amos
  //   31: 1, // Obadiah
  //   32: 4, // Jonah
  //   33: 7, // Micah
  //   34: 3, // Nahum
  //   35: 3, // Habakkuk
  //   36: 3, // Zephaniah
  //   37: 2, // Haggai
  //   38: 14, // Zechariah
  //   39: 4, // Malachi
  //   40: 28, // Matthew
  //   41: 16, // Mark
  //   42: 24, // Luke
  //   43: 21, // John
  //   44: 28, // Acts
  //   45: 16, // Romans
  //   46: 16, // 1 Corinthians
  //   47: 13, // 2 Corinthians
  //   48: 6, // Galatians
  //   49: 6, // Ephesians
  //   50: 4, // Philippians
  //   51: 4, // Colossians
  //   52: 5, // 1 Thessalonians
  //   53: 3, // 2 Thessalonians
  //   54: 6, // 1 Timothy
  //   55: 4, // 2 Timothy
  //   56: 3, // Titus
  //   57: 1, // Philemon
  //   58: 13, // Hebrews
  //   59: 5, // James
  //   60: 5, // 1 Peter
  //   61: 3, // 2 Peter
  //   62: 5, // 1 John
  //   63: 1, // 2 John
  //   64: 1, // 3 John
  //   65: 1, // Jude
  //   66: 22, // Revelation
  // };

  // Reverse mapping: number → abbreviation + full name
  static const Map<int, Map<String, String>> reverseBookMappings = {
    1: {'abbr': 'GEN', 'name': 'Genesis'},
    2: {'abbr': 'EXO', 'name': 'Exodus'},
    3: {'abbr': 'LEV', 'name': 'Leviticus'},
    4: {'abbr': 'NUM', 'name': 'Numbers'},
    5: {'abbr': 'DEU', 'name': 'Deuteronomy'},
    6: {'abbr': 'JOS', 'name': 'Joshua'},
    7: {'abbr': 'JDG', 'name': 'Judges'},
    8: {'abbr': 'RUT', 'name': 'Ruth'},
    9: {'abbr': '1SA', 'name': '1 Samuel'},
    10: {'abbr': '2SA', 'name': '2 Samuel'},
    11: {'abbr': '1KI', 'name': '1 Kings'},
    12: {'abbr': '2KI', 'name': '2 Kings'},
    13: {'abbr': '1CH', 'name': '1 Chronicles'},
    14: {'abbr': '2CH', 'name': '2 Chronicles'},
    15: {'abbr': 'EZR', 'name': 'Ezra'},
    16: {'abbr': 'NEH', 'name': 'Nehemiah'},
    17: {'abbr': 'EST', 'name': 'Esther'},
    18: {'abbr': 'JOB', 'name': 'Job'},
    19: {'abbr': 'PSA', 'name': 'Psalms'},
    20: {'abbr': 'PRO', 'name': 'Proverbs'},
    21: {'abbr': 'ECC', 'name': 'Ecclesiastes'},
    22: {'abbr': 'SNG', 'name': 'Song of Songs'},
    23: {'abbr': 'ISA', 'name': 'Isaiah'},
    24: {'abbr': 'JER', 'name': 'Jeremiah'},
    25: {'abbr': 'LAM', 'name': 'Lamentations'},
    26: {'abbr': 'EZK', 'name': 'Ezekiel'},
    27: {'abbr': 'DAN', 'name': 'Daniel'},
    28: {'abbr': 'HOS', 'name': 'Hosea'},
    29: {'abbr': 'JOL', 'name': 'Joel'},
    30: {'abbr': 'AMO', 'name': 'Amos'},
    31: {'abbr': 'OBA', 'name': 'Obadiah'},
    32: {'abbr': 'JON', 'name': 'Jonah'},
    33: {'abbr': 'MIC', 'name': 'Micah'},
    34: {'abbr': 'NAM', 'name': 'Nahum'},
    35: {'abbr': 'HAB', 'name': 'Habakkuk'},
    36: {'abbr': 'ZEP', 'name': 'Zephaniah'},
    37: {'abbr': 'HAG', 'name': 'Haggai'},
    38: {'abbr': 'ZEC', 'name': 'Zechariah'},
    39: {'abbr': 'MAL', 'name': 'Malachi'},
    40: {'abbr': 'MAT', 'name': 'Matthew'},
    41: {'abbr': 'MRK', 'name': 'Mark'},
    42: {'abbr': 'LUK', 'name': 'Luke'},
    43: {'abbr': 'JHN', 'name': 'John'},
    44: {'abbr': 'ACT', 'name': 'Acts'},
    45: {'abbr': 'ROM', 'name': 'Romans'},
    46: {'abbr': '1CO', 'name': '1 Corinthians'},
    47: {'abbr': '2CO', 'name': '2 Corinthians'},
    48: {'abbr': 'GAL', 'name': 'Galatians'},
    49: {'abbr': 'EPH', 'name': 'Ephesians'},
    50: {'abbr': 'PHP', 'name': 'Philippians'},
    51: {'abbr': 'COL', 'name': 'Colossians'},
    52: {'abbr': '1TH', 'name': '1 Thessalonians'},
    53: {'abbr': '2TH', 'name': '2 Thessalonians'},
    54: {'abbr': '1TI', 'name': '1 Timothy'},
    55: {'abbr': '2TI', 'name': '2 Timothy'},
    56: {'abbr': 'TIT', 'name': 'Titus'},
    57: {'abbr': 'PHM', 'name': 'Philemon'},
    58: {'abbr': 'HEB', 'name': 'Hebrews'},
    59: {'abbr': 'JAS', 'name': 'James'},
    60: {'abbr': '1PE', 'name': '1 Peter'},
    61: {'abbr': '2PE', 'name': '2 Peter'},
    62: {'abbr': '1JN', 'name': '1 John'},
    63: {'abbr': '2JN', 'name': '2 John'},
    64: {'abbr': '3JN', 'name': '3 John'},
    65: {'abbr': 'JUD', 'name': 'Jude'},
    66: {'abbr': 'REV', 'name': 'Revelation'},
  };

  static final List<int> allBooks = List.generate(66, (i) => i + 1);
  static final List<int> oldTestament = List.generate(39, (i) => i + 1);
  static final List<int> newTestament = List.generate(27, (i) => i + 40);

  static Map<int, String> getAllBookNames() {
    return {for (var n in allBooks) n: reverseBookMappings[n]!['name']!};
  }

  static String getBookAbbrByNumber(int n) {
    return reverseBookMappings[n]?['abbr'] ?? 'UNK';
  }

  static String getBookNameByNumber(int n) {
    return reverseBookMappings[n]?['name'] ?? 'Unknown Book';
  }

  static Map<int, String> getAllBookAbbr() {
    return {for (var n in allBooks) n: reverseBookMappings[n]!['abbr']!};
  }

  static Map<int, String> getOldTestamentNames() {
    return {for (var n in oldTestament) n: reverseBookMappings[n]!['name']!};
  }

  static Map<int, String> getNewTestamentNames() {
    return {for (var n in newTestament) n: reverseBookMappings[n]!['name']!};
  }

  /// Searches through book names and returns a Map of matching IDs and Names
  static Map<int, String> searchBooks(String query) {
    if (query.isEmpty) {
      return getAllBookNames();
    }

    final lowercaseQuery = query.toLowerCase();
    final allNames = getAllBookNames();

    // Returns a new map containing only entries where the name contains the query
    return Map.fromEntries(
      allNames.entries.where(
        (entry) => entry.value.toLowerCase().contains(lowercaseQuery),
      ),
    );
  }

  // static int getChapterCountForBook(int n) {
  //   return bookChapterCount[n] ?? 0;
  // }
}
