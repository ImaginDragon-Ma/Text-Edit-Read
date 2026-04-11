/// 本地文件服务
///
/// 平台适配的文件操作：
/// - mobile/desktop: file_picker + path_provider
/// - web: file_selector
/// 统一返回 TextFile 模型

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/file_handler.dart';
import '../../core/models/text_file.dart';

class LocalFileService {
  /// 打开文件选择器并读取内容
  Future<TextFile?> openFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'text', 'md', 'csv', 'log', 'json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final platformFile = result.files.first;

      if (kIsWeb) {
        // Web 平台
        if (platformFile.bytes == null) return null;
        final content = String.fromCharCodes(platformFile.bytes!);
        return TextFile(
          filePath: platformFile.name,
          fileName: platformFile.name,
          content: content,
          encoding: 'utf-8',
        );
      } else {
        // Mobile / Desktop 平台
        final path = platformFile.path;
        if (path == null || path.isEmpty) return null;

        final encoding = FileHandler.detectEncoding(path);
        final content = FileHandler.readFile(path, encoding: encoding);
        final name = path.split(Platform.pathSeparator).last;

        return TextFile(
          filePath: path,
          fileName: name,
          content: content,
          encoding: encoding,
        );
      }
    } catch (e) {
      throw Exception('打开文件失败: $e');
    }
  }

  /// 保存文件（已有路径直接覆盖）
  Future<void> saveFile(TextFile file) async {
    if (kIsWeb) {
      // Web 平台需要通过 saveFileAs 下载
      throw UnsupportedError('Web 平台请使用 saveFileAs');
    }

    try {
      final encoding = file.encoding ?? FileHandler.defaultEncoding;
      FileHandler.saveFile(file.filePath, file.content, encoding: encoding);
    } catch (e) {
      throw Exception('保存文件失败: $e');
    }
  }

  /// 另存为（弹出保存对话框）
  Future<String?> saveFileAs(TextFile file) async {
    try {
      if (kIsWeb) {
        // Web: file_picker 暂不直接支持 save，回退到下载
        // 可后续用 file_selector 的 SaveFileSelector
        throw UnsupportedError('Web 平台另存为暂未实现');
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: '另存为',
        fileName: file.fileName,
        allowedExtensions: ['txt', 'text', 'md'],
        type: FileType.custom,
      );

      if (result == null) return null;

      final encoding = file.encoding ?? FileHandler.defaultEncoding;
      FileHandler.saveFile(result, file.content, encoding: encoding);
      return result;
    } catch (e) {
      if (e is UnsupportedError) rethrow;
      throw Exception('另存为失败: $e');
    }
  }
}
