/// 章节检测模块
///
/// 从文本中检测章节标题并生成章节列表。
/// 对应 Python 版 ui/main_window.py 中的章节检测逻辑。

import 'models/chapter.dart';

class ChapterDetector {
  /// 章节标题正则：序章 或 第X章
  static final RegExp _chapterPattern =
      RegExp(r'(序章|第[一二三四五六七八九十百千零0-9]+章)');

  /// 从文本中检测所有章节
  ///
  /// 返回章节列表，每个章节包含标题、起始位置、结束位置
  static List<Chapter> detectChapters(String text) {
    final chapters = <Chapter>[];
    final matches = _chapterPattern.allMatches(text);

    if (matches.isEmpty) return chapters;

    final matchPositions = matches.map((m) => m.start).toList();

    for (var i = 0; i < matchPositions.length; i++) {
      final start = matchPositions[i];
      final end =
          i + 1 < matchPositions.length ? matchPositions[i + 1] : text.length;

      // 提取标题行（到行尾）
      final lineEnd = text.indexOf('\n', start);
      final titleEnd = lineEnd != -1 && lineEnd < end ? lineEnd : end;
      final title = text.substring(start, titleEnd).trim();

      // 计算章节字数（不含标题行）
      final contentStart = titleEnd + 1;
      final contentEnd = end;
      final charCount = contentStart < contentEnd
          ? text.substring(contentStart, contentEnd).replaceAll(RegExp(r'\s'), '').length
          : 0;

      chapters.add(Chapter(
        title: title,
        startIndex: start,
        endIndex: end,
        charCount: charCount,
      ));
    }

    return chapters;
  }

  /// 根据光标位置查找当前章节索引
  ///
  /// 返回章节索引（0-based），如果不在任何章节中返回 -1
  static int findCurrentChapter(List<Chapter> chapters, int cursorPosition) {
    for (var i = 0; i < chapters.length; i++) {
      if (cursorPosition >= chapters[i].startIndex &&
          cursorPosition < chapters[i].endIndex) {
        return i;
      }
    }
    return -1;
  }
}
