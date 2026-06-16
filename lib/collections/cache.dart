import 'package:isar/isar.dart';

part 'cache.g.dart';

@Collection()
class Cache {
  Id id = Isar.autoIncrement;
  late String version;
  late int book; // book number
  late int chapter; // chapter number
  late int verse; // verse number
  late String text; // verse text
  late int code; // color code
  DateTime timestamp = DateTime.now();
}
