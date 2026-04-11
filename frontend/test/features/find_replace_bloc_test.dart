import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:text_edit_read/features/find_replace/bloc/find_replace_bloc.dart';

void main() {
  group('FindReplaceBloc', () {
    late FindReplaceBloc bloc;

    setUp(() {
      bloc = FindReplaceBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(const FindReplaceState()));
    });

    blocTest<FindReplaceBloc, FindReplaceState>(
      'FindNext finds first match',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FindNext(
          text: 'hello world hello',
          searchTerm: 'hello',
          startPosition: 0,
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) =>
            s.totalMatches == 2 &&
            s.currentMatchIndex == 0 &&
            s.matchPosition == 0 &&
            s.matchLength == 5),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'FindNext wraps around',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FindNext(
          text: 'hello world',
          searchTerm: 'hello',
          startPosition: 100,
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) =>
            s.matchPosition == 0 && s.currentMatchIndex == 0),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'FindNext returns no match for empty search term',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FindNext(
          text: 'hello',
          searchTerm: '',
          startPosition: 0,
        ));
      },
      expect: () => [],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'FindNext reports zero matches when not found',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FindNext(
          text: 'hello',
          searchTerm: 'xyz',
          startPosition: 0,
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) =>
            s.totalMatches == 0 && s.matchPosition == null),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'FindPrevious finds match before position',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FindPrevious(
          text: 'hello world hello',
          searchTerm: 'hello',
          startPosition: 12,
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) =>
            s.matchPosition == 0 && s.currentMatchIndex == 0),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'ReplaceAll replaces all occurrences',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ReplaceAll(
          text: 'hello world hello',
          oldWord: 'hello',
          newWord: 'hi',
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) =>
            s.replaceCount == 2 &&
            s.replacedText == 'hi world hi'),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'ReplaceAll does nothing with empty oldWord',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ReplaceAll(
          text: 'hello',
          oldWord: '',
          newWord: 'hi',
        ));
      },
      expect: () => [],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'ReplaceExceptQuotes skips quoted text',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ReplaceExceptQuotes(
          text: '他说"hello"然后hello',
          oldWord: 'hello',
          newWord: 'hi',
        ));
      },
      expect: () => [
        predicate<FindReplaceState>((s) => s.replaceCount == 1),
      ],
    );

    blocTest<FindReplaceBloc, FindReplaceState>(
      'ClearSearch resets state',
      build: () => bloc,
      seed: () => const FindReplaceState(
        searchTerm: 'hello',
        totalMatches: 3,
        currentMatchIndex: 1,
      ),
      act: (bloc) {
        bloc.add(const ClearSearch());
      },
      expect: () => [
        const FindReplaceState(),
      ],
    );
  });
}
