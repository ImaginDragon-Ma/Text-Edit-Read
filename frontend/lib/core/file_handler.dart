/// 文件处理核心模块
import 'dart:convert';
import 'dart:io';

class FileHandler {
  static const String defaultEncoding = 'utf-8';
  static const int encodeDetectSampleSize = 4096;

  /// 检测文件编码
  static String detectEncoding(String filePath) {
    try {
      final file = File(filePath);
      final rawBytes = file.readAsBytesSync().take(encodeDetectSampleSize).toList();

      // 尝试 UTF-8
      try {
        utf8.decode(rawBytes);
        return 'utf-8';
      } catch (_) {}

      // 尝试 GBK (gb18030 兼容)
      try {
        final gbk = Encoding.getByName('gbk');
        if (gbk != null) gbk.decoder.convert(rawBytes);
        return 'gb18030';
      } catch (_) {}

      return defaultEncoding;
    } catch (e) {
      throw Exception('编码检测失败: $e');
    }
  }

  /// 读取文件内容
  static String readFile(String filePath, {String? encoding}) {
    encoding ??= detectEncoding(filePath);

    try {
      final content = File(filePath).readAsStringSync(
        encoding: Encoding.getByName(encoding) ?? utf8,
      );
      return content;
    } on FormatException catch (e) {
      try {
        final gbk = Encoding.getByName('gb18030');
        return File(filePath).readAsStringSync(encoding: gbk ?? utf8);
      } catch (e2) {
        throw Exception('文件解码失败，尝试编码 $encoding 和 gb18030 均失败: $e2');
      }
    } catch (e) {
      throw Exception('无法读取文件: $e');
    }
  }

  /// 保存文件内容
  static void saveFile(String filePath, String content, {String encoding = 'utf-8'}) {
    try {
      final file = File(filePath);
      final dir = file.parent;
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      file.writeAsStringSync(
        content,
        encoding: Encoding.getByName(encoding) ?? utf8,
      );
    } catch (e) {
      throw Exception('无法保存文件: $e');
    }
  }
}
