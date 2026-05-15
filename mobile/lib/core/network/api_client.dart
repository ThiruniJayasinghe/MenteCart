import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(responseBody: true, requestBody: true),
    ]);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final res = await _dio.get(path, queryParameters: params);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final res = await _dio.post(path, data: data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final res = await _dio.patch(path, data: data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppFailure _mapError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return AppFailure(
          message: data['message'] ?? 'An error occurred',
          errorCode: data['errorCode'],
          statusCode: e.response!.statusCode,
        );
      }
      return AppFailure(message: 'Server error', statusCode: e.response!.statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return const AppFailure(message: 'Connection timed out. Please check your internet.', errorCode: 'TIMEOUT');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AppFailure(message: 'No internet connection.', errorCode: 'NO_CONNECTION');
    }
    return AppFailure(message: e.message ?? 'Unknown error');
  }
}

final apiClient = ApiClient();