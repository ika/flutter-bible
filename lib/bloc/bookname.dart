import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';
import '../globals.dart';

//-------------------------------------------------------------
// Book Name Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}BookName';

/// Base class for book name-related events
abstract class BookNameEvent {}

/// Event to update the current bible book name
class UpdateBookName extends BookNameEvent {
  UpdateBookName({required this.bibleBookName});

  final String bibleBookName;
}

/// Bloc for managing the currently selected bible book name
/// Defaults to the book name from Globals (John)
class BookNameBloc extends HydratedBloc<BookNameEvent, String> {
  BookNameBloc() : super(Globals.bibleBookName) {
    on<UpdateBookName>((event, emit) => emit(event.bibleBookName));
  }

  @override
  String? fromJson(Map<String, dynamic> json) {
    try {
      return json[_hydratedBlocName] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(String state) => {_hydratedBlocName: state};

  @override
  String get id => _hydratedBlocName;
}
