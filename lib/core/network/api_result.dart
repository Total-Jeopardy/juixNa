sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  /// Pattern-match helper so you don't write `if (result is ...)` everywhere.
  R when<R>({
    required R Function(ApiSuccess<T> success) success,
    required R Function(ApiFailure<T> failure) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self);
    return failure(self as ApiFailure<T>);
  }
}

/// Success path: you got usable data back from the server.
final class ApiSuccess<T> extends ApiResult<T> {
  final T data;

  /// Optional, but nice for debugging/logging.
  final int? statusCode;

  const ApiSuccess(this.data, {this.statusCode});
}

/// Failure path: something went wrong (network, timeout, 401, validation, etc.)
final class ApiFailure<T> extends ApiResult<T> {
  final ApiError error;

  /// Optional status code if the server responded (e.g., 400, 401, 500).
  final int? statusCode;

  const ApiFailure(this.error, {this.statusCode});
}

/// A normalized error object that the UI/ViewModel can understand.
final class ApiError {
  /// Human-friendly message to show in UI (or logs).
  final String message;

  /// Machine-friendly category to drive UI decisions (retry, login, etc.)
  final ApiErrorType type;

  /// Optional extra info (validation fields, backend message, etc.)
  final Map<String, dynamic>? details;

  const ApiError({required this.message, required this.type, this.details});
}

/// Broad categories of failures we expect in real apps.
enum ApiErrorType {
  network, // no internet, DNS, socket
  timeout, // request took too long
  unauthorized, // 401 -> user must login again
  forbidden, // 403 -> user lacks permission
  notFound, // 404
  validation, // 400/422 -> input errors
  server, // 5xx
  cancelled, // request cancelled
  unknown, // anything else
}
