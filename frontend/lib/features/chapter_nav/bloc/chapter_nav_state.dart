part of 'chapter_nav_bloc.dart';

import '../../../core/models/chapter.dart';

class ChapterNavState extends Equatable {
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final bool isCollapsed;

  const ChapterNavState({
    this.chapters = const [],
    this.currentChapterIndex = -1,
    this.isCollapsed = false,
  });

  ChapterNavState copyWith({
    List<Chapter>? chapters,
    int? currentChapterIndex,
    bool? isCollapsed,
  }) {
    return ChapterNavState(
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }

  @override
  List<Object?> get props => [chapters, currentChapterIndex, isCollapsed];
}
