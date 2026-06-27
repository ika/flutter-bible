import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Verse Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}VerseNumber';

/// Base class for verse-related events
abstract class VerseEvent {}

/// Event to update the current verse number
class UpdateVerse extends VerseEvent {
  UpdateVerse({required this.verseNumber});

  final int verseNumber;
}

/// Bloc for managing the currently selected verse number
/// Defaults to verse 1
class VerseBloc extends HydratedBloc<VerseEvent, int> {
  VerseBloc() : super(1) {
    on<UpdateVerse>((event, emit) => emit(event.verseNumber));
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    try {
      return json[_hydratedBlocName] as int?;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(int state) => {_hydratedBlocName: state};

  @override
  String get id => _hydratedBlocName;
}
