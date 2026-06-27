import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Size Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}Size';

/// Base class for size-related events
abstract class SizeEvent {}

/// Event to update the text size
class UpdateSize extends SizeEvent {
  UpdateSize({required this.size});

  final double size;
}

/// Bloc for managing the text size setting
/// Defaults to 14.0
class SizeBloc extends HydratedBloc<SizeEvent, double> {
  SizeBloc() : super(16.0) {
    on<UpdateSize>((event, emit) => emit(event.size));
  }

  @override
  double? fromJson(Map<String, dynamic> json) {
    try {
      return json[_hydratedBlocName] as double?;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(double state) => {_hydratedBlocName: state};

  @override
  String get id => _hydratedBlocName;
}
