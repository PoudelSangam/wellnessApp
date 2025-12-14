import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class ApiService {
  final http.Client _client = http.Client();
  
  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      Logger.info('GET Request: $uri');
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.apiTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on HttpException {
      throw ApiException('Service unavailable', 0);
    } catch (e) {
      Logger.error('GET Error: $e');
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
      final uri = _buildUri(endpoint);
      
      Logger.info('POST Request: $uri');
      Logger.debug('Body: $body');
      
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.apiTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on HttpException {
      throw ApiException('Service unavailable', 0);
    } catch (e) {
      Logger.error('POST Error: $e');
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
      final uri = _buildUri(endpoint);
      
      Logger.info('PUT Request: $uri');
      
      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.apiTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on HttpException {
      throw ApiException('Service unavailable', 0);
    } catch (e) {
      Logger.error('PUT Error: $e');
      rethrow;
    }
  }
  
  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      Logger.info('DELETE Request: $uri');
      
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(ApiConstants.apiTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on HttpException {
      throw ApiException('Service unavailable', 0);
    } catch (e) {
      Logger.error('DELETE Error: $e');
      rethrow;
    }
  }
  
  // Build URI
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    
    return uri;
  }
  
  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    Logger.info('Response Status: ${response.statusCode}');
    Logger.info('Response Body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        Logger.error('JSON Decode Error: $e');
        Logger.error('Full Response Body: ${response.body}');
        throw ApiException('Invalid response format from server', response.statusCode);
      }
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden', 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Not found', 404);
    } else if (response.statusCode == 500) {
      throw ApiException('Server error', 500);
    } else {
      // Parse error response
      try {
        final errorBody = jsonDecode(response.body);
        
        // Check for validation errors (Django REST Framework format)
        if (errorBody is Map<String, dynamic>) {
          // Extract first error message from validation errors
          String? firstError;
          for (var entry in errorBody.entries) {
            if (entry.value is List && (entry.value as List).isNotEmpty) {
              firstError = '${entry.key}: ${entry.value[0]}';
              break;
            } else if (entry.value is String) {
              firstError = '${entry.key}: ${entry.value}';
              break;
            }
          }
          
          if (firstError != null) {
            throw ApiException(firstError, response.statusCode, errorBody);
          }
        }
        
        // Fallback to generic message
        final message = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['detail'] ??
                        'Request failed';
        throw ApiException(message, response.statusCode, errorBody);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Request failed', response.statusCode);
      }
    }
  }
  
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errorDetails;
  
  ApiException(this.message, this.statusCode, [this.errorDetails]);
  
  @override
  String toString() => message;
}
