import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_edit_read/shared/widgets/status_bar.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('StatusBar', () {
    testWidgets('shows word count', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(wordCount: 1234),
      ));
      expect(find.text('1234 字'), findsOneWidget);
    });

    testWidgets('shows chapter info when totalChapters > 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(currentChapter: 0, totalChapters: 5, wordCount: 100),
      ));
      expect(find.textContaining('章节 1 / 5'), findsOneWidget);
      expect(find.text('100 字'), findsOneWidget);
    });

    testWidgets('shows "序章" when currentChapter is -1', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(currentChapter: -1, totalChapters: 3, wordCount: 50),
      ));
      expect(find.textContaining('序章 / 3'), findsOneWidget);
    });

    testWidgets('hides chapter info when totalChapters is 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(totalChapters: 0, wordCount: 100),
      ));
      expect(find.textContaining('章节'), findsNothing);
      expect(find.text('100 字'), findsOneWidget);
    });

    testWidgets('shows selected char count when > 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(selectedCharCount: 42, wordCount: 100),
      ));
      expect(find.text('已选 42 字'), findsOneWidget);
    });

    testWidgets('hides selected char count when 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(selectedCharCount: 0, wordCount: 100),
      ));
      expect(find.textContaining('已选'), findsNothing);
    });

    testWidgets('has height 28', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatusBar(wordCount: 0),
      ));
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints, isNull);
      final renderBox = tester.renderObject<RenderBox>(find.byType(StatusBar));
      expect(renderBox.size.height, equals(28));
    });
  });
}
