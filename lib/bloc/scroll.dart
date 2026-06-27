import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Scroll Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}Scroll';

/// Base class for scroll-related events
abstract class ScrollEvent {}

/// Event to update the scroll index position
class UpdateScroll extends ScrollEvent {
  UpdateScroll({required this.index});

  final int index;
}

/// Bloc for managing the scroll position index
/// Defaults to index 0
class ScrollBloc extends HydratedBloc<ScrollEvent, int> {
  ScrollBloc() : super(0) {
    on<UpdateScroll>((event, emit) => emit(event.index));
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
