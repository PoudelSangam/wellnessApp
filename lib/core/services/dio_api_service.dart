import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class DioApiService {
  static final DioApiService _instance = DioApiService._internal();
  late final Dio _dio;

  factory DioApiService() {
    return _instance;
  }

  DioApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.apiTimeout,
      receiveTimeout: ApiConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Dio get dio => _dio;

  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data == null || response.data == '') {
      return {'success': true};
    } else {
      return {'data': response.data};
    }
  }

  void dispose() {
    _dio.close();
  }
}

// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.info('┌─────────────────────────────────────────────');
    Logger.info('│ REQUEST: ${options.method} ${options.uri}');
    Logger.info('│ Headers: ${options.headers}');
    if (options.data != null) {
      Logger.debug('│ Body: ${options.data}');
    }
    Logger.info('└─────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.info('┌─────────────────────────────────────────────');
    Logger.info('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    final responseData = response.data.toString();
    Logger.info('│ Data: ${responseData.length > 500 ? responseData.substring(0, 500) : responseData}');
    Logger.info('└─────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.error('┌─────────────────────────────────────────────');
    Logger.error('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    Logger.error('│ Status Code: ${err.response?.statusCode}');
    Logger.error('│ Message: ${err.message}');
    if (err.response?.data != null) {
      Logger.error('│ Response: ${err.response?.data}');
    }
    Logger.error('└─────────────────────────────────────────────');
    super.onError(err, handler);
  }
}

// Error Interceptor with User-Friendly Messages
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException apiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException(
          'Connection timeout. Please check your internet connection.',
          0,
        );
        break;

      case DioExceptionType.badResponse:
        apiException = _handleHttpError(err);
        break;

      case DioExceptionType.cancel:
        apiException = ApiException('Request cancelled', 0);
        break;

      case DioExceptionType.connectionError:
        apiException = ApiException(
          'No internet connection. Please check your network.',
          0,
        );
        break;

      case DioExceptionType.unknown:
        apiException = ApiException(
          'Unable to connect to server. Please try again later.',
          0,
        );
        break;

      default:
        apiException = ApiException(
          'Something went wrong. Please try again.',
          0,
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        response: err.response,
      ),
    );
  }

  ApiException _handleHttpError(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final data = err.response?.data;

    String message;

    switch (statusCode) {
      case 400:
        message = _extractErrorMessage(data) ?? 
                  'Bad request. Please check your input.';
        break;

      case 401:
        message = 'Session expired. Please login again.';
        break;

      case 403:
        message = 'Access denied. You don\'t have permission to perform this action.';
        break;

      case 404:
        message = 'Resource not found.';
        break;

      case 422:
        message = _extractErrorMessage(data) ?? 
                  'Validation failed. Please check your input.';
        break;

      case 429:
        message = 'Too many requests. Please try again later.';
        break;

      case 500:
        message = 'Server error. Please try again later.';
        break;

      case 502:
        message = 'Bad gateway. Server is temporarily unavailable.';
        break;

      case 503:
        message = 'Service unavailable. Please try again later.';
        break;

      default:
        message = _extractErrorMessage(data) ?? 
                  'Request failed (Error $statusCode). Please try again.';
    }

    return ApiException(message, statusCode, data);
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map<String, dynamic>) {
        // Check common error message fields
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['detail'] != null) return data['detail'].toString();

        // Django REST Framework validation errors
        if (data['non_field_errors'] != null && data['non_field_errors'] is List) {
          return (data['non_field_errors'] as List).first.toString();
        }

        // Extract first validation error
        for (var entry in data.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            final fieldName = entry.key.replaceAll('_', ' ');
            return '${fieldName[0].toUpperCase()}${fieldName.substring(1)}: ${entry.value[0]}';
          } else if (entry.value is String && entry.value.isNotEmpty) {
            final fieldName = entry.key.replaceAll('_', ' ');
            return '${fieldName[0].toUpperCase()}${fieldName.substring(1)}: ${entry.value}';
          }
        }
      } else if (data is String) {
        return data;
      }
    } catch (e) {
      Logger.error('Error extracting message: $e');
    }

    return null;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic errorDetails;

  ApiException(this.message, this.statusCode, [this.errorDetails]);

  @override
  String toString() => message;

  // Helper method to show error in UI
  void showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForStatusCode(),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: _getColorForStatusCode(),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  IconData _getIconForStatusCode() {
    if (statusCode == 0) return Icons.wifi_off;
    if (statusCode == 401) return Icons.lock_outline;
    if (statusCode == 403) return Icons.block;
    if (statusCode == 404) return Icons.search_off;
    if (statusCode >= 500) return Icons.error_outline;
    return Icons.warning_amber;
  }

  Color _getColorForStatusCode() {
    if (statusCode == 0) return Colors.orange;
    if (statusCode == 401 || statusCode == 403) return Colors.red[700]!;
    if (statusCode == 404) return Colors.blue[700]!;
    if (statusCode >= 500) return Colors.red[900]!;
    return Colors.orange[800]!;
  }
}
