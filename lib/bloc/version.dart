import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// UpdateVersion
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}BibleVersion';

abstract class VersionEvent {}

class UpdateVersion extends VersionEvent {
  UpdateVersion({required this.bibleVersion});

  final String bibleVersion;
}

class VersionBloc extends HydratedBloc<VersionEvent, String> {
  VersionBloc() : super('nvlg') {
    on<UpdateVersion>((event, emit) => emit(event.bibleVersion));
  }

  @override
  String? fromJson(Map<String, dynamic> json) => json[hydratedBlocName];

  @override
  Map<String, dynamic>? toJson(String state) => {hydratedBlocName: state};
}
