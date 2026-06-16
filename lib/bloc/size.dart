import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

String hydratedBlocName = '${Constants.projectName}Size';

// -------------------------------------------------
// Event
// -------------------------------------------------

abstract class SizeEvent {}

class UpdateSize extends SizeEvent {
  UpdateSize({required this.size});
  final double size;
}

// -------------------------------------------------
// Bloc
// -------------------------------------------------
class SizeBloc extends HydratedBloc<SizeEvent, double> {
  SizeBloc() : super(14.0) {
    on<UpdateSize>((event, emit) {
      emit(event.size);
    });
  }

  @override
  double? fromJson(Map<String, dynamic> json) =>
      json[hydratedBlocName] as double;

  @override
  Map<String, dynamic>? toJson(double state) => {hydratedBlocName: state};
}
