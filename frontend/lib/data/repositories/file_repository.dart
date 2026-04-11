/// 文件仓库
///
/// 统一本地/远程接口：
/// - 优先本地操作（离线可用）
/// - 可选远程同步（后端可用时）

import '../../core/models/text_file.dart';
import '../services/local_file_service.dart';
import '../services/api_client.dart';
import '../services/api_service.dart';

enum FileSource { local, remote }

class FileRepository {
  final LocalFileService _localService;
  final ApiClient _apiClient;
  late final ApiService _apiService;
  bool _useRemote = false;

  FileRepository({
    required LocalFileService localService,
    required ApiClient apiClient,
  }) : _localService = localService,
       _apiClient = apiClient {
    _apiService = ApiService(apiClient);
  }

  /// 检查远程是否可用并自动切换
  Future<bool> checkRemote() async {
    _useRemote = await _apiClient.isAvailable();
    return _useRemote;
  }

  /// 手动设置是否使用远程
  void setUseRemote(bool use) {
    _useRemote = use;
  }

  /// 获取当前数据源
  FileSource get source => _useRemote ? FileSource.remote : FileSource.local;

  /// 打开文件
  Future<TextFile?> openFile() async {
    return await _localService.openFile();
  }

  /// 保存文件
  Future<void> saveFile(TextFile file) async {
    await _localService.saveFile(file);

    if (_useRemote) {
      try {
        await _apiService.saveFile(
          file.filePath,
          file.content,
          encoding: file.encoding ?? 'utf-8',
        );
      } catch (_) {
        // 远程失败不影响本地保存
      }
    }
  }

  /// 另存为
  Future<String?> saveFileAs(TextFile file) async {
    return await _localService.saveFileAs(file);
  }
}
