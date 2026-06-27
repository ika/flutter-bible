import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Version Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}BibleVersion';

/// Base class for version-related events
abstract class VersionEvent {}

/// Event to update the current bible version
class UpdateVersion extends VersionEvent {
  UpdateVersion({required this.bibleVersion});

  final String bibleVersion;
}

/// Bloc for managing the currently selected bible version
/// Defaults to 'nvlg' (New Vulgate)
class VersionBloc extends HydratedBloc<VersionEvent, String> {
  VersionBloc() : super('nvlg') {
    on<UpdateVersion>((event, emit) => emit(event.bibleVersion));
  }

  @override
  String? fromJson(Map<String, dynamic> json) {
    try {
      return json[_hydratedBlocName] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(String state) => {_hydratedBlocName: state};

  @override
  String get id => _hydratedBlocName;
}
