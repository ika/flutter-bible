import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Selector Count
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}SelectorCount';

abstract class SelectorCountEvent {}

class UpdateSelectorCount extends SelectorCountEvent {
  UpdateSelectorCount({required this.selectorCount});

  final int selectorCount;
}

class SelectorCountBloc extends HydratedBloc<SelectorCountEvent, int> {
  SelectorCountBloc() : super(1) {
    on<UpdateSelectorCount>((event, emit) => emit(event.selectorCount));
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {hydratedBlocName: state};
}
