import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Book Bloc
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}BookNumber';

abstract class BookEvent {}

class UpdateBook extends BookEvent {
  UpdateBook({required this.bibleBookNumber});
  final int bibleBookNumber;
}

class BookNumberBloc extends HydratedBloc<BookEvent, int> {
  BookNumberBloc() : super(43) {
    on<UpdateBook>((event, emit) => emit(event.bibleBookNumber));
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {hydratedBlocName: state};
}
