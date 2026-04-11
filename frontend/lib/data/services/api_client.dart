/// 基于 Dio 的 HTTP 客户端
///
/// 配置 baseUrl、超时、错误处理

import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String baseUrl = 'http://localhost:8000', Duration? connectTimeout}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: false),
    ]);
  }

  /// GET 请求
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST 请求
  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 更新 baseUrl
  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// 检查后端是否可用
  Future<bool> isAvailable() async {
    try {
      await _dio.get('/health', options: Options(receiveTimeout: const Duration(seconds: 3)));
      return true;
    } catch (_) {
      return false;
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('连接超时，请检查后端服务是否运行');
      case DioExceptionType.connectionError:
        return Exception('无法连接到服务器');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final message = e.response?.data?['detail'] ?? '未知错误';
        return Exception('服务器错误 ($status): $message');
      default:
        return Exception('网络请求失败: ${e.message}');
    }
  }
}
