import 'package:dio/dio.dart';
import '../../../core/utils/logger.dart';
import '../models/chat_response.dart';

class ChatException implements Exception {
  final String message;

  ChatException(this.message);

  @override
  String toString() => message;
}

class ChatService {
  static const String _baseUrl = 'https://chat.sangam1313.com.np';

  final Dio _dio;

  ChatService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  Future<ChatResponse> sendMessage(String message) async {
    try {
      Logger.debug('Chat request: POST $_baseUrl/chat');
      Logger.debug('Chat payload: {"message":"$message"}');

      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
        },
      );

      Logger.debug(
        'Chat response: ${response.statusCode} ${response.data}',
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatResponse.fromJson(data);
      }

      throw ChatException('Unexpected response from chat server.');
    } on DioException catch (e) {
      Logger.error(
        'Chat error: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
      final errorMessage = _extractErrorMessage(e.response?.data) ??
          e.message ??
          'Unable to reach chat server.';
      throw ChatException(errorMessage);
    } catch (_) {
      throw ChatException('Something went wrong. Please try again.');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic> && first['msg'] != null) {
          return first['msg'].toString();
        }
      }

      if (data['message'] is String) {
        return data['message'] as String;
      }
    }

    return null;
  }
}
