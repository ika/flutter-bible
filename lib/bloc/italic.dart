import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Italic Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}Italic';

/// Base class for italic-related events
abstract class ItalicEvent {}

/// Event to change the italic text setting
class ChangeItalic extends ItalicEvent {
  ChangeItalic({required this.italicIsOn});

  final bool italicIsOn;
}

/// Bloc for managing the italic text setting
/// Defaults to false (italic text off)
class ItalicBloc extends HydratedBloc<ItalicEvent, bool> {
  ItalicBloc() : super(false) {
    on<ChangeItalic>((event, emit) => emit(event.italicIsOn));
  }

  @override
  bool? fromJson(Map<String, dynamic> json) {
    try {
      return json[_hydratedBlocName] as bool?;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(bool state) => {_hydratedBlocName: state};

  @override
  String get id => _hydratedBlocName;
}
