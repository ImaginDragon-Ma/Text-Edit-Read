import 'package:test/test.dart';
import 'package:text_edit_read/core/text_processor.dart';

void main() {
  group('TextProcessor.cleanText', () {
    test('删除开头空格', () {
      final result = TextProcessor.cleanText('   hello world');
      expect(result, isNot(contains(RegExp(r'^\s+'))));
    });

    test('删除空白段落', () {
      final input = 'hello\n\n\nworld';
      final result = TextProcessor.cleanText(input);
      expect(result, contains('hello'));
      expect(result, contains('world'));
      expect(result, isNot(contains('\n\n\n')));
    });

    test('章节标题前后添加空行并缩进段落', () {
      final input = '第一章 测试\n这是第一段\n这是第二段';
      final result = TextProcessor.cleanText(input);
      // 章节标题不缩进
      expect(result, contains('第一章 测试'));
      // 普通段落有中文空格缩进
      expect(result, contains('\u3000\u3000这是第一段'));
      expect(result, contains('\u3000\u3000这是第二段'));
    });

    test('序章标题处理', () {
      final input = '序章\n故事开始';
      final result = TextProcessor.cleanText(input);
      expect(result, contains('序章'));
      expect(result, contains('\u3000\u3000故事开始'));
    });

    test('空文本返回空', () {
      final result = TextProcessor.cleanText('');
      expect(result, isEmpty);
    });

    test('多章节间距和缩进', () {
      final input = '第一章 开始\n段落一\n第二章 继续\n段落二';
      final result = TextProcessor.cleanText(input);
      // 章节间有空行
      expect(result.split('第一章 开始').last.split('第二章 继续').first, contains('\n\n'));
    });
  });

  group('TextProcessor.findText', () {
    test('向前查找', () {
      final (pos, matched) = TextProcessor.findText('hello world hello', 'world');
      expect(pos, 6);
      expect(matched, 'world');
    });

    test('向后查找', () {
      final (pos, matched) = TextProcessor.findText('hello world hello', 'hello', start_pos: 10, direction: 'previous');
      expect(pos, 0);
      expect(matched, 'hello');
    });

    test('未找到返回 null', () {
      final (pos, matched) = TextProcessor.findText('hello', 'xyz');
      expect(pos, isNull);
      expect(matched, isNull);
    });

    test('空搜索词返回 null', () {
      final (pos, matched) = TextProcessor.findText('hello', '');
      expect(pos, isNull);
      expect(matched, isNull);
    });
  });

  group('TextProcessor.replaceAllWord', () {
    test('替换所有匹配', () {
      final lines = ['hello world', 'hello again'];
      final (result, count) = TextProcessor.replaceAllWord(lines, 'hello', 'hi');
      expect(result, ['hi world', 'hi again']);
      expect(count, 2);
    });

    test('无匹配时不变', () {
      final lines = ['abc def'];
      final (result, count) = TextProcessor.replaceAllWord(lines, 'xyz', 'hi');
      expect(result, ['abc def']);
      expect(count, 0);
    });
  });

  group('TextProcessor.replaceExceptInQuotes', () {
    test('替换引号外内容', () {
      final lines = ['他说"hello"然后hello'];
      final (result, count) = TextProcessor.replaceExceptInQuotes(lines, 'hello', 'hi');
      // "hello" 不替换，外面的 hello 替换
      expect(result.first, contains('"hello"'));
      expect(result.first, contains('然后hi'));
      expect(count, 1);
    });

    test('中文双引号内不替换', () {
      final lines = ['\u201c你好\u201d 你好'];
      final (result, count) = TextProcessor.replaceExceptInQuotes(lines, '你好', '您好');
      expect(result.first, contains('\u201c你好\u201d'));
      expect(result.first, contains('您好'));
      expect(count, 1);
    });
  });
}
