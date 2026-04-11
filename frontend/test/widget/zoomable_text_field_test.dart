import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_edit_read/shared/widgets/zoomable_text_field.dart';

void main() {
  Widget buildTestWidget({
    required TextEditingController controller,
    double fontSize = 16.0,
    required ValueChanged<double> onFontSizeChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ZoomableTextField(
          controller: controller,
          focusNode: FocusNode(),
          fontSize: fontSize,
          onFontSizeChanged: onFontSizeChanged,
          onCursorPositionChanged: (_) {},
          onSelectionStartChanged: (_) {},
          onSelectionEndChanged: (_) {},
        ),
      ),
    );
  }

  group('ZoomableTextField', () {
    testWidgets('renders TextField with initial fontSize', (tester) async {
      final controller = TextEditingController(text: 'Hello World');
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        fontSize: 20.0,
        onFontSizeChanged: (_) {},
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, equals(20.0));
    });

    testWidgets('displays initial text content', (tester) async {
      final controller = TextEditingController(text: 'Test content');
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        onFontSizeChanged: (_) {},
      ));

      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('shows placeholder when empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        onFontSizeChanged: (_) {},
      ));

      expect(find.text('打开文件开始编辑...'), findsOneWidget);
    });

    testWidgets('expands to fill available space', (tester) async {
      final controller = TextEditingController(text: 'text');
      await tester.pumpWidget(buildTestWidget(
        controller: controller,
        onFontSizeChanged: (_) {},
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.expands, isTrue);
      expect(textField.maxLines, isNull);
    });
  });
}
