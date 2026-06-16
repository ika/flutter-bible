import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

String hydratedBlocName = '${Constants.projectName}Italic';

// -------------------------------------------------
// Event
// -------------------------------------------------

abstract class ItalicEvent {}

class ChangeItalic extends ItalicEvent {
  ChangeItalic({required this.italicIsOn});
  final bool italicIsOn;
}

// -------------------------------------------------
// Bloc
// -------------------------------------------------
class ItalicBloc extends HydratedBloc<ItalicEvent, bool> {
  ItalicBloc() : super(false) {
    on<ChangeItalic>((event, emit) {
      emit(event.italicIsOn);
    });
  }

  @override
  bool? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as bool;

  @override
  Map<String, dynamic>? toJson(bool state) => {hydratedBlocName: state};
}
