import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exceptions.dart';
import 'api_result.dart';

/// Returns the current auth token (or null if not logged in).
typedef TokenProvider = FutureOr<String?> Function();

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final TokenProvider? _tokenProvider;
  final Duration timeout;
  final ApiErrorMapper _errorMapper;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
    TokenProvider? tokenProvider,
    this.timeout = const Duration(seconds: 25),
    ApiErrorMapper? errorMapper,
  }) : _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _errorMapper = errorMapper ?? const ApiErrorMapper();

  /// Call this if you created ApiClient once and want to dispose it (optional).
  void close() => _client.close();

  // ---------------------------
  // Public convenience methods
  // ---------------------------

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
    Map<String, String>? headers,
  }) {
    return _request<T>(
      method: 'GET',
      path: path,
      query: query,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
    Map<String, String>? headers,
    bool useFormData = false, // For endpoints that expect form-encoded data
  }) {
    return _request<T>(
      method: 'POST',
      path: path,
      query: query,
      body: body,
      headers: headers,
      parse: parse,
      useFormData: useFormData,
    );
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
    Map<String, String>? headers,
  }) {
    return _request<T>(
      method: 'PUT',
      path: path,
      query: query,
      body: body,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
    Map<String, String>? headers,
  }) {
    return _request<T>(
      method: 'DELETE',
      path: path,
      query: query,
      body: body,
      headers: headers,
      parse: parse,
    );
  }

  // ---------------------------
  // Core request method
  // ---------------------------

  Future<ApiResult<T>> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? headers,
    required T Function(dynamic json) parse,
    bool useFormData = false,
  }) async {
    final uri = _buildUri(path, query);

    // Debug: Log the base URL and full URI for troubleshooting
    if (path.contains('/auth/login')) {
      print('🔵 Making request to:');
      print('   Base URL: $baseUrl');
      print('   Full URI: $uri');
      print('   Method: $method');
    }

    try {
      final mergedHeaders = await _buildHeaders(
        extra: headers,
        useFormData: useFormData,
      );

      final http.Request request = http.Request(method, uri);
      request.headers.addAll(mergedHeaders);

      if (body != null) {
        if (useFormData && body is Map<String, dynamic>) {
          // Convert to form-encoded format (application/x-www-form-urlencoded)
          // bodyFields automatically URL-encodes values
          // Note: When bodyFields is set, http package automatically sets Content-Type
          // but we're also setting it manually to ensure consistency
          final formData = <String, String>{};
          body.forEach((key, value) {
            if (value != null) {
              formData[key] = value.toString();
            }
          });
          request.bodyFields = formData;

          // Debug logging for login requests
          if (path.contains('/auth/login')) {
            print('🔵 Login Request (Form Data):');
            print('   URL: $uri');
            print('   useFormData: $useFormData');
            print('   Headers: ${request.headers}');
            print('   Body Fields: $formData');
            print('   Body Type: ${body.runtimeType}');
          }
        } else {
          // Default: JSON encoding
          request.body = jsonEncode(body);

          // Debug logging for login requests
          if (path.contains('/auth/login')) {
            print('🔵 Login Request (JSON):');
            print('   URL: $uri');
            print('   useFormData: $useFormData');
            print('   Headers: ${request.headers}');
            print('   Body: ${request.body}');
            print('   Body Type: ${body.runtimeType}');
          }
        }
      }

      final streamed = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);

      final status = response.statusCode;
      final rawBody = response.body;

      // Success (2xx)
      if (status >= 200 && status < 300) {
        final dynamic decoded = _decodeJsonSafely(rawBody);
        final T data = parse(decoded);
        return ApiSuccess<T>(data, statusCode: status);
      }

      // Failure (non-2xx)
      final serverPayload = _decodeJsonSafely(rawBody);
      final serverMessage =
          _extractServerMessage(serverPayload) ?? response.reasonPhrase;
      final details = _extractDetails(serverPayload);

      // Debug: Log the full error response for troubleshooting
      // Remove this in production or make it conditional on debug mode
      if (status == 401 || status == 422) {
        print('🔴 API Error Response:');
        print('   Status: $status');
        print('   Message: $serverMessage');
        print('   Details: $details');
        print('   Raw Body: $rawBody');
      }

      final apiError = _errorMapper.fromStatusCode(
        status,
        messageFromServer: serverMessage,
        details: details,
      );

      return ApiFailure<T>(apiError, statusCode: status);
    } on ApiRequestCancelled catch (e) {
      return ApiFailure<T>(_errorMapper.fromException(e));
    } on TimeoutException catch (e) {
      print('⏱️ Request timeout for: $uri');
      return ApiFailure<T>(_errorMapper.fromException(e));
    } on SocketException catch (e) {
      print('🌐 Network error (SocketException) for: $uri');
      print('   Error: ${e.message}');
      print('   OS Error: ${e.osError}');
      return ApiFailure<T>(_errorMapper.fromException(e));
    } on Exception catch (e) {
      // Any other exception (network/socket/etc.) gets normalized here.
      print('❌ Unexpected exception for: $uri');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      return ApiFailure<T>(_errorMapper.fromException(e));
    }
  }

  // ---------------------------
  // Helpers
  // ---------------------------

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');

    if (query == null || query.isEmpty) return uri;

    // Convert query values to strings; ignore nulls
    final qp = <String, String>{};
    for (final entry in query.entries) {
      final v = entry.value;
      if (v == null) continue;
      qp[entry.key] = v.toString();
    }

    return uri.replace(queryParameters: qp);
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? extra,
    bool useFormData = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': useFormData
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
    };

    // Attach token if available
    if (_tokenProvider != null) {
      final token = await _tokenProvider.call();
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extra != null && extra.isNotEmpty) {
      headers.addAll(extra);
    }

    return headers;
  }

  dynamic _decodeJsonSafely(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      // Not JSON (some servers return plain text)
      return raw;
    }
  }

  /// Try to find a human-readable message from typical backend shapes.
  String? _extractServerMessage(dynamic payload) {
    if (payload == null) return null;

    // If backend returns plain text
    if (payload is String) return payload;

    if (payload is Map<String, dynamic>) {
      // Common keys
      final candidates = [
        payload['message'],
        payload['detail'],
        payload['error'],
        payload['title'],
      ];

      for (final c in candidates) {
        if (c is String && c.trim().isNotEmpty) return c;
      }
    }

    return null;
  }

  /// Try to pull a details object for validation errors, etc.
  Map<String, dynamic>? _extractDetails(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      // Typical validation shapes: { errors: {...} } or { detail: [...] }
      final errors = payload['errors'];
      if (errors is Map<String, dynamic>) return errors;

      final detail = payload['detail'];
      if (detail is Map<String, dynamic>) return detail;

      // Otherwise keep whole map as details (useful for debugging)
      return payload;
    }

    return null;
  }
}
