import 'package:isar/isar.dart';

part 'word.g.dart';

@Collection()
class Word {
  Id id = Isar.autoIncrement; // id
  late String lat; // lat text
  late String eng; // eng definition
}