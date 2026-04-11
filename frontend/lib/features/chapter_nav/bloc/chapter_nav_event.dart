part of 'chapter_nav_bloc.dart';

abstract class ChapterNavEvent extends Equatable {
  const ChapterNavEvent();

  @override
  List<Object?> get props => [];
}

class RefreshChapters extends ChapterNavEvent {
  final String text;
  const RefreshChapters(this.text);

  @override
  List<Object?> get props => [text];
}

class JumpToChapter extends ChapterNavEvent {
  final int chapterIndex;
  const JumpToChapter(this.chapterIndex);

  @override
  List<Object?> get props => [chapterIndex];
}

class EditChapterTitle extends ChapterNavEvent {
  final int chapterIndex;
  final String newTitle;
  const EditChapterTitle({required this.chapterIndex, required this.newTitle});

  @override
  List<Object?> get props => [chapterIndex, newTitle];
}

class ToggleCollapse extends ChapterNavEvent {
  const ToggleCollapse();
}

class SetCurrentChapter extends ChapterNavEvent {
  final int chapterIndex;
  const SetCurrentChapter(this.chapterIndex);

  @override
  List<Object?> get props => [chapterIndex];
}
