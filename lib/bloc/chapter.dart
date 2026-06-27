import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Chapter Bloc
//-------------------------------------------------------------

const String _hydratedBlocName = '${Constants.projectName}ChapterNumber';

/// Base class for chapter-related events
abstract class ChapterEvent {}

/// Event to update the current chapter number
class UpdateChapter extends ChapterEvent {
  UpdateChapter({required this.chapterNumber});

  final int chapterNumber;
}

/// Bloc for managing the currently selected chapter number
/// Defaults to chapter 1
class ChapterBloc extends HydratedBloc<ChapterEvent, int> {
  ChapterBloc() : super(1) {
    on<UpdateChapter>((event, emit) => emit(event.chapterNumber));
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
