import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:text_edit_read/features/text_processing/bloc/text_processing_bloc.dart';

void main() {
  group('TextProcessingBloc', () {
    late TextProcessingBloc bloc;

    setUp(() {
      bloc = TextProcessingBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.isProcessing, isFalse);
      expect(bloc.state.cleanedText, isNull);
      expect(bloc.state.error, isNull);
    });

    blocTest<TextProcessingBloc, TextProcessingState>(
      'CleanText cleans text and produces result',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const CleanText('  \n\n测试文本\n\n'));
      },
      expect: () => [
        predicate<TextProcessingState>((s) => s.isProcessing),
        predicate<TextProcessingState>((s) =>
            !s.isProcessing &&
            s.cleanedText != null &&
            s.cleanedText!.contains('测试文本')),
      ],
    );

    blocTest<TextProcessingBloc, TextProcessingState>(
      'CleanText adds chapter spacing and indentation',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const CleanText('第一章 开始\n这是内容\n这是另一段'));
      },
      expect: () => [
        predicate<TextProcessingState>((s) =>
            !s.isProcessing &&
            s.cleanedText != null &&
            s.cleanedText!.contains('\u3000\u3000')), // double full-width space indent
      ],
    );
  });
}
