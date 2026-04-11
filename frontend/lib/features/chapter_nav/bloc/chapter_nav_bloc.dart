import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/chapter_detector.dart';
import '../../../core/models/chapter.dart';

part 'chapter_nav_event.dart';
part 'chapter_nav_state.dart';

class ChapterNavBloc extends Bloc<ChapterNavEvent, ChapterNavState> {
  ChapterNavBloc() : super(const ChapterNavState()) {
    on<RefreshChapters>(_onRefreshChapters);
    on<JumpToChapter>(_onJumpToChapter);
    on<EditChapterTitle>(_onEditChapterTitle);
    on<SetCurrentChapter>(_onSetCurrentChapter);
  }

  void _onRefreshChapters(RefreshChapters event, Emitter<ChapterNavState> emit) {
    final chapters = ChapterDetector.detectChapters(event.text);
    emit(state.copyWith(chapters: chapters));
  }

  void _onJumpToChapter(JumpToChapter event, Emitter<ChapterNavState> emit) {
    if (event.chapterIndex >= 0 && event.chapterIndex < state.chapters.length) {
      emit(state.copyWith(currentChapterIndex: event.chapterIndex));
    }
  }

  void _onEditChapterTitle(EditChapterTitle event, Emitter<ChapterNavState> emit) {
    if (event.chapterIndex < 0 || event.chapterIndex >= state.chapters.length) return;

    final updated = List<Chapter>.from(state.chapters);
    final old = updated[event.chapterIndex];
    updated[event.chapterIndex] = Chapter(
      title: event.newTitle,
      startIndex: old.startIndex,
      endIndex: old.endIndex,
      charCount: old.charCount,
    );
    emit(state.copyWith(chapters: updated));
  }

  void _onToggleCollapse(ToggleCollapse event, Emitter<ChapterNavState> emit) {
    emit(state.copyWith(isCollapsed: !state.isCollapsed));
  }

  void _onSetCurrentChapter(SetCurrentChapter event, Emitter<ChapterNavState> emit) {
    emit(state.copyWith(currentChapterIndex: event.chapterIndex));
  }
}
