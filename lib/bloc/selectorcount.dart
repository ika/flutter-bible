import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Selector Count Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}SelectorCount';

/// Base class for selector count-related events
abstract class SelectorCountEvent {}

/// Event to update the selector count
class UpdateSelectorCount extends SelectorCountEvent {
  UpdateSelectorCount({required this.selectorCount});

  final int selectorCount;
}

/// Bloc for managing the selector count value
/// Defaults to 1
class SelectorCountBloc extends HydratedBloc<SelectorCountEvent, int> {
  SelectorCountBloc() : super(1) {
    on<UpdateSelectorCount>((event, emit) => emit(event.selectorCount));
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
