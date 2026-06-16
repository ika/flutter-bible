import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../constants.dart';

String hydratedBlocName = '${Constants.projectName}Scroll';

// -------------------------------------------------
// Event
// -------------------------------------------------

abstract class ScrollEvent {}

class UpdateScroll extends ScrollEvent {
  UpdateScroll({required this.index});
  final int index;
}

// -------------------------------------------------
// Bloc
// -------------------------------------------------
class ScrollBloc extends HydratedBloc<ScrollEvent, int> {
  ScrollBloc() : super(0) {
    on<UpdateScroll>((event, emit) {
      emit(event.index);
    });
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {hydratedBlocName: state};
}
