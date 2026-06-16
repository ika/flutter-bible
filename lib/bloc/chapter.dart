import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../constants.dart';

//-------------------------------------------------------------
// Chapter Bloc
//-------------------------------------------------------------

String hydratedBlocName = '${Constants.projectName}ChapterNumber';

abstract class ChapterEvent {}

class UpdateChapter extends ChapterEvent {
  UpdateChapter({required this.chapterNumber});

  final int chapterNumber;
}

class ChapterBloc extends HydratedBloc<ChapterEvent, int> {
  ChapterBloc() : super(1) {
    on<UpdateChapter>((event, emit) => emit(event.chapterNumber));
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json[hydratedBlocName] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {hydratedBlocName: state};
}
