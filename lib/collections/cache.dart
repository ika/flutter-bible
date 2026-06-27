import 'package:isar/isar.dart';

part 'cache.g.dart';

@collection
class Cache {
  Cache(); // Default constructor

  Id id = Isar.autoIncrement;
  late String version;
  late int book; // book number
  late int chapter; // chapter number
  late int verse; // verse number
  late String text; // verse text
  late int code; // color code
  DateTime timestamp = DateTime.now();

  // Convert Cache object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create Cache object from JSON
  factory Cache.fromJson(Map<String, dynamic> json) {
    return Cache()
      ..id = json['id'] as int
      ..version = json['version'] as String
      ..book = json['book'] as int
      ..chapter = json['chapter'] as int
      ..verse = json['verse'] as int
      ..text = json['text'] as String
      ..code = json['code'] as int
      ..timestamp = DateTime.parse(json['timestamp'] as String);
  }
}
