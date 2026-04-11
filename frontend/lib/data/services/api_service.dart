/// API 服务层
///
/// 调用 FastAPI 后端接口，返回对应 Dart 模型

import '../../core/models/replace_result.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  /// POST /api/text/clean — 清理文本
  Future<String> cleanText(String text) async {
    final response = await _client.post('/api/text/clean', data: {'text': text});
    return response.data['cleaned_text'] as String;
  }

  /// POST /api/text/find — 查找文本
  ///
  /// 返回 (位置, 匹配文本)，未找到返回 (null, null)
  Future<(int?, String?)> findText(
    String text,
    String searchTerm, {
    int startPos = 0,
    String direction = 'next',
  }) async {
    final response = await _client.post('/api/text/find', data: {
      'text': text,
      'search_term': searchTerm,
      'start_pos': startPos,
      'direction': direction,
    });

    final data = response.data;
    if (data['position'] == null) return (null, null);
    return (data['position'] as int, data['matched_text'] as String);
  }

  /// POST /api/text/replace-all — 替换所有
  Future<ReplaceResult> replaceAll(String text, String oldWord, String newWord) async {
    final response = await _client.post('/api/text/replace-all', data: {
      'text': text,
      'old_word': oldWord,
      'new_word': newWord,
    });

    final data = response.data;
    return ReplaceResult(
      lines: List<String>.from(data['lines'] as List),
      count: data['count'] as int,
    );
  }

  /// POST /api/text/replace-except-quotes — 替换双引号外的内容
  Future<ReplaceResult> replaceExceptInQuotes(
    String text,
    String oldWord,
    String newWord,
  ) async {
    final response = await _client.post('/api/text/replace-except-quotes', data: {
      'text': text,
      'old_word': oldWord,
      'new_word': newWord,
    });

    final data = response.data;
    return ReplaceResult(
      lines: List<String>.from(data['lines'] as List),
      count: data['count'] as int,
    );
  }

  /// POST /api/file/read — 远程读取文件
  Future<String> readFile(String filePath) async {
    final response = await _client.post('/api/file/read', data: {
      'file_path': filePath,
    });
    return response.data['content'] as String;
  }

  /// POST /api/file/save — 远程保存文件
  Future<void> saveFile(String filePath, String content, {String encoding = 'utf-8'}) async {
    await _client.post('/api/file/save', data: {
      'file_path': filePath,
      'content': content,
      'encoding': encoding,
    });
  }

  /// POST /api/file/detect-encoding — 远程检测编码
  Future<String> detectEncoding(String filePath) async {
    final response = await _client.post('/api/file/detect-encoding', data: {
      'file_path': filePath,
    });
    return response.data['encoding'] as String;
  }
}
