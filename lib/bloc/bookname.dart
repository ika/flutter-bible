import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';
import '../globals.dart';

//-------------------------------------------------------------
// UpdateBookName
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}BookName';

abstract class BookNameEvent {}

class UpdateBookName extends BookNameEvent {
  UpdateBookName({required this.bibleBookName});

  final String bibleBookName;
}

class BookNameBloc extends HydratedBloc<BookNameEvent, String> {
  BookNameBloc() : super(Globals.bibleBookName) {
    on<UpdateBookName>((event, emit) => emit(event.bibleBookName));
  }

  @override
  String? fromJson(Map<String, dynamic> json) =>
      json[hydratedBlocName] as String;

  @override
  Map<String, dynamic>? toJson(String state) => {hydratedBlocName: state};
}
