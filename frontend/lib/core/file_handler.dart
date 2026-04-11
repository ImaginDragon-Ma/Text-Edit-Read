/// 文件处理核心模块
///
/// 提供文件编码检测、读取、保存等功能。
/// 功能等价于 Python 版 src/core/file_handler.py
///
/// 注意：Dart/Flutter 没有直接的 chardet 等价物，
/// 编码检测使用 dart:convert 的 fallback 策略。

import 'dart:convert';
import 'dart:io';

class FileHandler {
  static const String defaultEncoding = 'utf-8';
  static const int encodeDetectSampleSize = 4096;
  static const double encodingConfidenceThreshold = 0.7;

  /// 检测文件编码
  ///
  /// Dart 没有 chardet，使用简化策略：
  /// 1. 尝试 UTF-8 解码采样字节
  /// 2. 如果失败，尝试 GBK (gb18030 兼容)
  /// 3. 都失败则返回默认 UTF-8
  static String detectEncoding(String filePath) {
    try {
      final file = File(filePath);
      final rawBytes = file.readAsBytesSync().take(encodeDetectSampleSize).toList();

      // 尝试 UTF-8
      try {
        utf8.decode(rawBytes);
        return 'utf-8';
      } catch (_) {
        // 不是有效 UTF-8
      }

      // 尝试 GBK (gb18030 兼容)
      try {
        gbk.decode(rawBytes);
        return 'gb18030';
      } catch (_) {
        // 不是有效 GBK
      }

      return defaultEncoding;
    } catch (e) {
      throw Exception('编码检测失败: $e');
    }
  }

  /// 读取文件内容
  ///
  /// 如果 encoding 为 null 则自动检测
  static String readFile(String filePath, {String? encoding}) {
    encoding ??= detectEncoding(filePath);

    try {
      final content = File(filePath).readAsStringSync(encoding: Encoding.getByName(encoding));
      return content;
    } on FormatException catch (e) {
      // 解码失败，尝试 gb18030
      try {
        return File(filePath).readAsStringSync(encoding: Encoding.getByName('gb18030'));
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
      file.writeAsStringSync(content, encoding: Encoding.getByName(encoding));
    } catch (e) {
      throw Exception('无法保存文件: $e');
    }
  }
}
