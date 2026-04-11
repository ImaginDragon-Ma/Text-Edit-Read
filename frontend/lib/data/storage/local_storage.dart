/// 基于 Hive 的本地 KV 存储
///
/// 用于存储配置、缓存等键值对数据

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String _boxName = 'app_storage';

  /// 初始化（在 app 启动时调用）
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  /// 读取字符串
  String? getString(String key, {String? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as String?;
  }

  /// 写入字符串
  Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  /// 读取整数
  int? getInt(String key, {int? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as int?;
  }

  /// 写入整数
  Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  /// 读取布尔值
  bool? getBool(String key, {bool? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as bool?;
  }

  /// 写入布尔值
  Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  /// 读取对象（JSON 序列化）
  T? getObject<T>(String key) {
    final value = _box.get(key);
    if (value == null) return null;
    // Hive 可以直接存储 Map/List
    return value as T?;
  }

  /// 写入对象
  Future<void> setObject(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// 删除 key
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  /// 检查 key 是否存在
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  /// 清空所有数据
  Future<void> clear() async {
    await _box.clear();
  }
}
