import 'dart:io';
import 'package:test/test.dart';
import 'package:text_edit_read/core/file_handler.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('text_edit_read_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileHandler.saveFile & readFile', () {
    test('保存和读取 UTF-8 文件', () {
      final filePath = '${tempDir.path}/test.txt';
      const content = '你好世界\nHello World';
      FileHandler.saveFile(filePath, content);
      final result = FileHandler.readFile(filePath);
      expect(result, content);
    });

    test('覆盖写入', () {
      final filePath = '${tempDir.path}/test.txt';
      FileHandler.saveFile(filePath, 'old');
      FileHandler.saveFile(filePath, 'new');
      expect(FileHandler.readFile(filePath), 'new');
    });
  });

  group('FileHandler.detectEncoding', () {
    test('UTF-8 文本检测为 utf-8', () {
      final filePath = '${tempDir.path}/utf8.txt';
      File(filePath).writeAsBytesSync(utf8.encode('你好世界'));
      final encoding = FileHandler.detectEncoding(filePath);
      expect(encoding, 'utf-8');
    });

    test('GBK 文本检测为 gb18030', () {
      final filePath = '${tempDir.path}/gbk.txt';
      // "测试" in GBK encoding
      final gbkBytes = [0xB2, 0xE2, 0xCA, 0xD4];
      File(filePath).writeAsBytesSync(gbkBytes);
      final encoding = FileHandler.detectEncoding(filePath);
      expect(encoding, 'gb18030');
    });
  });

  group('FileHandler.readFile fallback', () {
    test('指定编码读取', () {
      final filePath = '${tempDir.path}/test.txt';
      File(filePath).writeAsStringSync('内容', encoding: utf8);
      final result = FileHandler.readFile(filePath, encoding: 'utf-8');
      expect(result, '内容');
    });
  });
}
