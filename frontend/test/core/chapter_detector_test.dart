import 'package:test/test.dart';
import 'package:text_edit_read/core/chapter_detector.dart';

void main() {
  group('ChapterDetector.detectChapters', () {
    test('检测单个章节', () {
      const text = '第一章 开始\n正文内容\n更多内容';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters.length, 1);
      expect(chapters[0].title, '第一章 开始');
      expect(chapters[0].startIndex, 0);
    });

    test('检测多个章节', () {
      const text = '第一章 开始\n内容\n第二章 继续\n更多内容';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters.length, 2);
      expect(chapters[0].title, '第一章 开始');
      expect(chapters[1].title, '第二章 继续');
    });

    test('检测序章', () {
      const text = '序章\n故事从这里开始';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters.length, 1);
      expect(chapters[0].title, '序章');
    });

    test('无章节时返回空列表', () {
      const text = '这是一段没有章节的文本';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters, isEmpty);
    });

    test('阿拉伯数字章节', () {
      const text = '第1章 开始\n内容';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters.length, 1);
      expect(chapters[0].title, '第1章 开始');
    });

    test('章节字数统计', () {
      const text = '第一章 标题\n一二三\n第二章 标题二\n四五六';
      final chapters = ChapterDetector.detectChapters(text);
      expect(chapters[0].charCount, greaterThan(0));
      expect(chapters[1].charCount, greaterThan(0));
    });
  });

  group('ChapterDetector.findCurrentChapter', () {
    test('光标在章节内返回正确索引', () {
      const text = '第一章 开始\n内容\n第二章 继续\n更多';
      final chapters = ChapterDetector.detectChapters(text);
      expect(ChapterDetector.findCurrentChapter(chapters, 0), 0);
      expect(ChapterDetector.findCurrentChapter(chapters, text.indexOf('内容')), 0);
      expect(ChapterDetector.findCurrentChapter(chapters, text.indexOf('更多')), 1);
    });

    test('光标不在任何章节中返回 -1', () {
      const text = '第一章 开始\n内容';
      final chapters = ChapterDetector.detectChapters(text);
      expect(ChapterDetector.findCurrentChapter(chapters, 999), -1);
    });
  });
}
