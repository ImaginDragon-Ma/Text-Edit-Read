import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_edit_read/shared/widgets/file_tab_bar.dart';
import 'package:text_edit_read/core/models/text_file.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  final testFile1 = TextFile(
    filePath: '/tmp/test1.txt',
    fileName: 'test1.txt',
    content: 'hello',
  );
  final testFile2 = TextFile(
    filePath: '/tmp/test2.txt',
    fileName: 'test2.txt',
    content: 'world',
  );
  final modifiedFile = TextFile(
    filePath: '/tmp/modified.txt',
    fileName: 'modified.txt',
    content: 'changed',
    isModified: true,
  );

  group('FileTabBar', () {
    testWidgets('renders nothing when no files open', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FileTabBar(
          openFiles: [],
          onTabSwitch: (_) {},
          onTabClose: (_) {},
        ),
      ));
      expect(find.byType(FileTabBar), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders tabs for open files', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FileTabBar(
          openFiles: [testFile1, testFile2],
          onTabSwitch: (_) {},
          onTabClose: (_) {},
        ),
      ));
      expect(find.text('test1.txt'), findsOneWidget);
      expect(find.text('test2.txt'), findsOneWidget);
    });

    testWidgets('calls onTabSwitch when tab tapped', (tester) async {
      String? switchedPath;
      await tester.pumpWidget(buildTestWidget(
        FileTabBar(
          openFiles: [testFile1, testFile2],
          onTabSwitch: (path) => switchedPath = path,
          onTabClose: (_) {},
        ),
      ));
      await tester.tap(find.text('test2.txt'));
      expect(switchedPath, equals('/tmp/test2.txt'));
    });

    testWidgets('calls onTabClose when close icon tapped', (tester) async {
      String? closedPath;
      await tester.pumpWidget(buildTestWidget(
        FileTabBar(
          openFiles: [testFile1],
          onTabSwitch: (_) {},
          onTabClose: (path) => closedPath = path,
        ),
      ));
      // Find the close icon (InkWell with Icon)
      final closeIcons = find.byIcon(Icons.close);
      expect(closeIcons, findsOneWidget);
      await tester.tap(closeIcons);
      expect(closedPath, equals('/tmp/test1.txt'));
    });

    testWidgets('shows modified indicator dot', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FileTabBar(
          openFiles: [modifiedFile],
          onTabSwitch: (_) {},
          onTabClose: (_) {},
        ),
      ));
      // The modified indicator is a small circle (Container with shape)
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );
      // At least one container should be a small circle (6x6)
      expect(containers.any((c) {
        final box = c.constraints?.maxWidth == 6;
        return c.decoration is BoxDecoration;
      }), isTrue);
    });
  });
}
