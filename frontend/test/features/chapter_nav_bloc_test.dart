import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:text_edit_read/features/chapter_nav/bloc/chapter_nav_bloc.dart';
import 'package:text_edit_read/core/models/chapter.dart';

void main() {
  group('ChapterNavBloc', () {
    late ChapterNavBloc bloc;

    setUp(() {
      bloc = ChapterNavBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(const ChapterNavState()));
    });

    blocTest<ChapterNavBloc, ChapterNavState>(
      'RefreshChapters detects chapters',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const RefreshChapters(
          '第一章 开始\n内容\n第二章 继续\n更多内容',
        ));
      },
      expect: () => [
        predicate<ChapterNavState>((s) => s.chapters.length == 2),
      ],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'RefreshChapters detects prologue',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const RefreshChapters('序章\n一些内容'));
      },
      expect: () => [
        predicate<ChapterNavState>((s) =>
            s.chapters.length == 1 &&
            s.chapters.first.title.contains('序章')),
      ],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'JumpToChapter sets currentChapterIndex',
      build: () => bloc,
      seed: () => ChapterNavState(
        chapters: [
          Chapter(title: '第一章', startIndex: 0, endIndex: 10, charCount: 10),
          Chapter(title: '第二章', startIndex: 10, endIndex: 20, charCount: 10),
          Chapter(title: '第三章', startIndex: 20, endIndex: 30, charCount: 10),
        ],
      ),
      act: (bloc) {
        bloc.add(const JumpToChapter(2));
      },
      expect: () => [
        predicate<ChapterNavState>((s) => s.currentChapterIndex == 2),
      ],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'JumpToChapter ignores out of range index',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const JumpToChapter(99));
      },
      expect: () => [],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'EditChapterTitle updates chapter title',
      build: () => bloc,
      seed: () => ChapterNavState(
        chapters: [
          Chapter(title: '第一章', startIndex: 0, endIndex: 10, charCount: 10),
        ],
      ),
      act: (bloc) {
        bloc.add(const EditChapterTitle(chapterIndex: 0, newTitle: '新标题'));
      },
      expect: () => [
        predicate<ChapterNavState>((s) =>
            s.chapters.first.title == '新标题' &&
            s.chapters.first.startIndex == 0),
      ],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'EditChapterTitle ignores out of range index',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const EditChapterTitle(chapterIndex: -1, newTitle: 'x'));
      },
      expect: () => [],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'SetCurrentChapter updates current index',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const SetCurrentChapter(3));
      },
      expect: () => [
        const ChapterNavState(currentChapterIndex: 3),
      ],
    );

    blocTest<ChapterNavBloc, ChapterNavState>(
      'ToggleCollapse toggles isCollapsed',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ToggleCollapse());
        bloc.add(const ToggleCollapse());
      },
      expect: () => [
        const ChapterNavState(isCollapsed: true),
        const ChapterNavState(isCollapsed: false),
      ],
    );
  });
}
