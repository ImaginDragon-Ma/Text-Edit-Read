import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:text_edit_read/features/editor/bloc/editor_bloc.dart';

void main() {
  group('EditorBloc', () {
    late EditorBloc bloc;

    setUp(() {
      bloc = EditorBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(const EditorState()));
    });

    blocTest<EditorBloc, EditorState>(
      'SetFontSize clamps value to 12-72 range',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const SetFontSize(5.0));
        bloc.add(const SetFontSize(100.0));
        bloc.add(const SetFontSize(24.0));
      },
      skip: 2,
      expect: () => [
        const EditorState(fontSize: 24.0),
      ],
    );

    blocTest<EditorBloc, EditorState>(
      'ToggleTheme toggles isDarkTheme',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ToggleTheme());
        bloc.add(const ToggleTheme());
      },
      expect: () => [
        const EditorState(isDarkTheme: true),
        const EditorState(isDarkTheme: false),
      ],
    );

    blocTest<EditorBloc, EditorState>(
      'UpdateText updates text and word count',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const UpdateText('Hello World 你好'));
      },
      expect: () => [
        predicate<EditorState>((s) =>
            s.text == 'Hello World 你好' &&
            s.wordCount == 'HelloWorld你好'.length),
      ],
    );

    blocTest<EditorBloc, EditorState>(
      'UpdateText detects chapters',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const UpdateText('第一章 开始\n内容\n第二章 继续\n更多'));
      },
      expect: () => [
        predicate<EditorState>((s) => s.totalChapters == 2),
      ],
    );

    blocTest<EditorBloc, EditorState>(
      'CursorChanged updates cursor position and chapter',
      build: () => bloc,
      seed: () => const EditorState(
        text: '第一章 开始\n内容\n第二章 继续\n更多',
        totalChapters: 2,
      ),
      act: (bloc) {
        bloc.add(const CursorChanged(
          position: 15,
          selectionStart: 15,
          selectionEnd: 15,
        ));
      },
      expect: () => [
        predicate<EditorState>((s) =>
            s.cursorPosition == 15 && s.currentChapter >= 0),
      ],
    );

    blocTest<EditorBloc, EditorState>(
      'CursorChanged calculates selectedCharCount',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const CursorChanged(
          position: 10,
          selectionStart: 3,
          selectionEnd: 10,
        ));
      },
      expect: () => [
        predicate<EditorState>((s) => s.selectedCharCount == 7),
      ],
    );
  });
}
