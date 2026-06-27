import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Font Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}Font';

/// Base class for font-related events
abstract class FontEvent {}

/// Event to update the current font selection
class UpdateFont extends FontEvent {
  UpdateFont({required this.font});

  final int font;
}

/// Bloc for managing the currently selected font
/// Defaults to font 7
class FontBloc extends HydratedBloc<FontEvent, int> {
  FontBloc() : super(7) {
    on<UpdateFont>((event, emit) => emit(event.font));
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
