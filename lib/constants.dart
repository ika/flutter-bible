//-------------------------------------------------------------
// Constants
//-------------------------------------------------------------

class Constants {
  static const Map<String, Map<String, String>> bibleVersions = {
    'nvlg': {
      'name': 'New Vulgate',
      'lang': 'lat',
      'number': '1',
    },
    'cpdv': {
      'name': 'Catholic Public Domain',
      'lang': 'eng',
      'number': '2',
    },
    'clem': {
      'name': 'Clementine Vulgate',
      'lang': 'lat',
      'number': '3',
    },
    'webpb': {
      'name': 'World English Bible',
      'lang': 'eng',
      'number': '4',
    },
    'esv': {
      'name': 'English Standard Version',
      'lang': 'eng',
      'number': '5',
    },
    'kjv': {
      'name': 'King James Version',
      'lang': 'eng',
      'number': '6',
    },
  };

  static const List<String> bibleLanguages = ['eng', 'lat'];

  static const String projectName = "NewVulgate"; // used in Bloc file names
}
