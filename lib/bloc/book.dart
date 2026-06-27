import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../constants.dart';

//-------------------------------------------------------------
// Book Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}BookNumber';

/// Base class for book-related events
abstract class BookEvent {}

/// Event to update the current bible book number
class UpdateBook extends BookEvent {
  UpdateBook({required this.bibleBookNumber});

  final int bibleBookNumber;
}

/// Bloc for managing the currently selected bible book number
/// Defaults to book 43 (Gospel of John)
class BookNumberBloc extends HydratedBloc<BookEvent, int> {
  BookNumberBloc() : super(43) {
    on<UpdateBook>((event, emit) => emit(event.bibleBookNumber));
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
