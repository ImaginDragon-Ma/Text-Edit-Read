/// 文本文件模型
class TextFile {
  final String filePath;
  final String fileName;
  String content;
  String? encoding;
  bool isModified;

  TextFile({
    required this.filePath,
    required this.fileName,
    required this.content,
    this.encoding,
    this.isModified = false,
  });
}
