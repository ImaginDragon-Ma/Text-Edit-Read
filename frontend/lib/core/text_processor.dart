/// 文本处理核心模块
///
/// 提供文本清理、查找、替换等核心功能。
/// 功能等价于 Python 版 src/core/text_processor.py

class TextProcessor {
  static const String _chineseSpace = '\u3000';

  /// 章节标题正则：序章 或 第X章（中文数字+阿拉伯数字）
  static final RegExp _chapterPattern =
      RegExp(r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)');

  /// 清理文本
  ///
  /// 执行以下操作：
  /// - 删除开头空格
  /// - 删除空白段落
  /// - 分离章节标题为独立段落
  /// - 章节间保留空行
  /// - 为段落开头添加两个中文空格缩进
  static String cleanText(String text) {
    text = _removeAllLeadingSpaces(text);
    text = _removeEmptyParagraphs(text);
    text = _insertFirstChapter(text);
    text = _separateChapterTitles(text);
    text = _addChapterSpacing(text);
    text = _addParagraphIndent(text);
    return text;
  }

  /// 删除开头空格
  static String _removeAllLeadingSpaces(String text) {
    // lstrip: remove leading whitespace
    return text.replaceFirst(RegExp(r'^\s+'), '');
  }

  /// 删除空白段落
  static String _removeEmptyParagraphs(String text) {
    return text.split('\n').where((line) => line.trim().isNotEmpty).join('\n');
  }

  /// 检测章节标题（保留用于向后兼容，不修改文本）
  static String _insertFirstChapter(String text) {
    return text;
  }

  /// 分离章节标题为独立段落
  static String _separateChapterTitles(String text) {
    final lines = text.split('\n');
    final result = <String>[];

    for (final line in lines) {
      if (_chapterPattern.hasMatch(line)) {
        result.add(line.trim());
      } else if (line.trim().isNotEmpty) {
        result.add(line.trim());
      } else if (line.isEmpty) {
        result.add('');
      }
    }

    return result.join('\n');
  }

  /// 在章节标题前后添加空行
  static String _addChapterSpacing(String text) {
    final lines = text.split('\n');
    final result = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (_chapterPattern.hasMatch(line)) {
        // 在章节标题前添加空行
        if (result.isNotEmpty && result.last.isNotEmpty) {
          result.add('');
        }
        result.add(line.trim());
        // 在章节标题后添加空行
        if (i < lines.length - 1 && lines[i + 1].trim().isNotEmpty) {
          result.add('');
        }
      } else if (line.trim().isNotEmpty) {
        result.add(line.trim());
      } else if (line.isEmpty) {
        result.add('');
      }
    }

    return result.join('\n');
  }

  /// 为段落开头添加两个中文空格缩进（章节标题除外）
  static String _addParagraphIndent(String text) {
    final lines = <String>[];

    for (final line in text.split('\n')) {
      final stripped = line.trim();
      if (stripped.isNotEmpty) {
        if (_chapterPattern.hasMatch(stripped)) {
          lines.add(stripped);
        } else {
          lines.add('$_chineseSpace$_chineseSpace$stripped');
        }
      } else {
        lines.add('');
      }
    }

    return lines.join('\n');
  }

  /// 查找文本中的目标词
  ///
  /// [direction]: 'next' 或 'previous'
  /// 返回 (位置, 匹配的文本)，未找到时返回 (null, null)
  static (int?, String?) findText(
    String text,
    String searchTerm, {
    int start_pos = 0,
    String direction = 'next',
  }) {
    if (searchTerm.isEmpty) return (null, null);

    try {
      final escaped = RegExp.escape(searchTerm);
      final pattern = RegExp(escaped);

      if (direction == 'next') {
        final match = pattern.search(text, start_pos);
        if (match != null) {
          return (match.start, match.group(0));
        }
      } else if (direction == 'previous') {
        final reversePos = start_pos - 1;
        if (reversePos >= 0) {
          final before = text.substring(0, reversePos);
          final reversed = before.split('').reversed.join();
          final match = pattern.search(reversed);
          if (match != null) {
            final pos = reversePos - match.end;
            return (pos, match.group(0));
          }
        }
      }

      return (null, null);
    } catch (e) {
      throw Exception('文本查找失败: $e');
    }
  }

  /// 替换所有行中的指定单词
  ///
  /// 返回 (替换后的行列表, 替换数量)
  static (List<String>, int) replaceAllWord(
    List<String> lines,
    String oldWord,
    String newWord,
  ) {
    final result = <String>[];
    var count = 0;

    for (final line in lines) {
      final occurrences = oldWord.allMatches(line).length;
      count += occurrences;
      result.add(line.replaceAll(oldWord, newWord));
    }

    return (result, count);
  }

  /// 替换双引号外的指定单词
  ///
  /// 中英文双引号内的内容不替换
  /// 返回 (替换后的行列表, 替换数量)
  static (List<String>, int) replaceExceptInQuotes(
    List<String> lines,
    String oldWord,
    String newWord,
  ) {
    var count = 0;
    final result = <String>[];

    // 匹配：中文双引号内容 | 英文双引号内容 | 非引号内容
    final quotePattern = RegExp(r'\u201c[^\u201d]*\u201d|"[^"]*"|[^\u201c\u201d"]+');

    for (final line in lines) {
      final replaced = line.replaceAllMapped(quotePattern, (match) {
        final text = match.group(0)!;
        // 检查是否为引号包裹的内容
        if ((text.startsWith('\u201c') && text.endsWith('\u201d')) ||
            (text.startsWith('"') && text.endsWith('"'))) {
          return text;
        }
        final occurrences = oldWord.allMatches(text).length;
        count += occurrences;
        return text.replaceAll(oldWord, newWord);
      });
      result.add(replaced);
    }

    return (result, count);
  }
}
