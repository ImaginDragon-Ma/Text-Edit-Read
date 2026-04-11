/// 章节模型
class Chapter {
  final String title;
  final int startIndex;
  final int endIndex;
  int charCount;

  Chapter({
    required this.title,
    required this.startIndex,
    required this.endIndex,
    this.charCount = 0,
  });
}
