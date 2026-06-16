import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Verse Bloc
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}VerseNumber';

abstract class VerseEvent {}

class UpdateVerse extends VerseEvent {
  UpdateVerse({required this.verseNumber});

  final int verseNumber;
}

class VerseBloc extends HydratedBloc<VerseEvent, int> {
  VerseBloc() : super(1) {
    on<UpdateVerse>((event, emit) => emit(event.verseNumber));
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {hydratedBlocName: state};
}
