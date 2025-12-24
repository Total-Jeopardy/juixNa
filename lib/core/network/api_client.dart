import 'dart:async';
import 'dart:convert';

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
  }) {
    return _request<T>(
      method: 'POST',
      path: path,
      query: query,
      body: body,
      headers: headers,
      parse: parse,
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
  }) async {
    final uri = _buildUri(path, query);

    try {
      final mergedHeaders = await _buildHeaders(extra: headers);

      final http.Request request = http.Request(method, uri);
      request.headers.addAll(mergedHeaders);

      if (body != null) {
        request.body = jsonEncode(body);
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

      final apiError = _errorMapper.fromStatusCode(
        status,
        messageFromServer: serverMessage,
        details: details,
      );

      return ApiFailure<T>(apiError, statusCode: status);
    } on ApiRequestCancelled catch (e) {
      return ApiFailure<T>(_errorMapper.fromException(e));
    } on TimeoutException catch (e) {
      return ApiFailure<T>(_errorMapper.fromException(e));
    } on Exception catch (e) {
      // Any other exception (network/socket/etc.) gets normalized here.
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
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
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
