/// 设置仓库
///
/// 管理 App 设置：字体大小、编码、主题等

import '../storage/local_storage.dart';

class SettingsRepository {
  final LocalStorage _storage;

  // Keys
  static const String keyFontSize = 'font_size';
  static const String keyEncoding = 'default_encoding';
  static const String keyTheme = 'theme';
  static const String keyLastFilePath = 'last_file_path';
  static const String keyLastCursorPosition = 'last_cursor_position';
  static const String keyUseRemote = 'use_remote';
  static const String keyServerUrl = 'server_url';

  SettingsRepository({required LocalStorage storage}) : _storage = storage;

  // ── 字体大小 ──

  double getFontSize({double defaultValue = 14.0}) {
    return _storage.getInt(keyFontSize)?.toDouble() ?? defaultValue;
  }

  Future<void> setFontSize(double size) async {
    await _storage.setInt(keyFontSize, size.round());
  }

  // ── 默认编码 ──

  String getEncoding({String defaultValue = 'utf-8'}) {
    return _storage.getString(keyEncoding, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> setEncoding(String encoding) async {
    await _storage.setString(keyEncoding, encoding);
  }

  // ── 主题 ──

  String getTheme({String defaultValue = 'system'}) {
    return _storage.getString(keyTheme, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> setTheme(String theme) async {
    await _storage.setString(keyTheme, theme);
  }

  // ── 最近文件 ──

  String? getLastFilePath() {
    return _storage.getString(keyLastFilePath);
  }

  Future<void> setLastFilePath(String path) async {
    await _storage.setString(keyLastFilePath, path);
  }

  int getLastCursorPosition({int defaultValue = 0}) {
    return _storage.getInt(keyLastCursorPosition, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> setLastCursorPosition(int position) async {
    await _storage.setInt(keyLastCursorPosition, position);
  }

  // ── 远程设置 ──

  bool getUseRemote({bool defaultValue = false}) {
    return _storage.getBool(keyUseRemote, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> setUseRemote(bool use) async {
    await _storage.setBool(keyUseRemote, use);
  }

  String getServerUrl({String defaultValue = 'http://localhost:8000'}) {
    return _storage.getString(keyServerUrl, defaultValue: defaultValue) ?? defaultValue;
  }

  Future<void> setServerUrl(String url) async {
    await _storage.setString(keyServerUrl, url);
  }
}
