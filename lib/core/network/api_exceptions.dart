import 'dart:async';
import 'dart:io';

import 'api_result.dart';

/// A small utility to convert low-level errors + HTTP status codes
/// into our normalized [ApiError] (message + type + details).
class ApiErrorMapper {
  const ApiErrorMapper();

  /// Map based on HTTP status code (when the server responded).
  ApiError fromStatusCode(
    int statusCode, {
    String? messageFromServer,
    Map<String, dynamic>? details,
  }) {
    switch (statusCode) {
      case 400:
      case 422:
        return ApiError(
          message:
              messageFromServer ?? 'Invalid request. Please check your input.',
          type: ApiErrorType.validation,
          details: details,
        );
      case 401:
        return ApiError(
          message: messageFromServer ?? 'Session expired. Please log in again.',
          type: ApiErrorType.unauthorized,
          details: details,
        );
      case 403:
        return ApiError(
          message:
              messageFromServer ??
              'You do not have permission to perform this action.',
          type: ApiErrorType.forbidden,
          details: details,
        );
      case 404:
        return ApiError(
          message: messageFromServer ?? 'Resource not found.',
          type: ApiErrorType.notFound,
          details: details,
        );
      default:
        if (statusCode >= 500) {
          return ApiError(
            message: messageFromServer ?? 'Server error. Please try again.',
            type: ApiErrorType.server,
            details: details,
          );
        }
        return ApiError(
          message: messageFromServer ?? 'Unexpected error occurred.',
          type: ApiErrorType.unknown,
          details: details,
        );
    }
  }

  /// Map based on thrown exceptions (when the request failed before the server responded).
  ApiError fromException(Object error) {
    // Timeouts (Future timeout, HttpClient timeout, etc.)
    if (error is TimeoutException) {
      return const ApiError(
        message: 'Request timed out. Please try again.',
        type: ApiErrorType.timeout,
      );
    }

    // No internet / DNS / socket issues
    if (error is SocketException) {
      return const ApiError(
        message: 'No internet connection. Check your network and retry.',
        type: ApiErrorType.network,
      );
    }

    // Request cancelled
    if (error is ApiRequestCancelled) {
      return const ApiError(
        message: 'Request cancelled.',
        type: ApiErrorType.cancelled,
      );
    }

    // Fallback
    return ApiError(
      message: 'Something went wrong. Please try again.',
      type: ApiErrorType.unknown,
      details: {'raw': error.toString()},
    );
  }
}

/// A simple cancellation signal we can throw from ApiClient
/// (e.g., when a screen is disposed or user leaves a page).
class ApiRequestCancelled implements Exception {
  final String? reason;
  ApiRequestCancelled([this.reason]);

  @override
  String toString() =>
      reason == null ? 'ApiRequestCancelled' : 'ApiRequestCancelled: $reason';
}
