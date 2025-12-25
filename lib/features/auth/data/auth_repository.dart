import 'package:juix_na/core/auth/token_store.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/auth/data/auth_api.dart';
import 'package:juix_na/features/auth/model/auth_dtos.dart';
import 'package:juix_na/features/auth/model/user_models.dart';

/// Repository for authentication operations.
/// Wraps AuthApi and handles token storage.
class AuthRepository {
  final AuthApi _authApi;
  final TokenStore _tokenStore;

  AuthRepository({
    required AuthApi authApi,
    required TokenStore tokenStore,
  })  : _authApi = authApi,
        _tokenStore = tokenStore;

  /// Login with email and password.
  /// 
  /// 1. Calls AuthApi.login()
  /// 2. On success: saves token to TokenStore
  /// 3. Converts UserDTO to User domain model
  /// 
  /// Returns ApiResult<User>:
  /// - Success: User domain model (token already saved)
  /// - Failure: ApiError from API call
  Future<ApiResult<User>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authApi.login(email: email, password: password);

    if (result.isSuccess) {
      final success = result as ApiSuccess<LoginResponseDTO>;
      final loginResponse = success.data;

      // Save token to secure storage
      await _tokenStore.saveAccessToken(loginResponse.accessToken);

      // Convert DTO to domain model
      final user = User.fromDTO(loginResponse.user);

      return ApiSuccess(user);
    } else {
      final failure = result as ApiFailure<LoginResponseDTO>;
      return ApiFailure<User>(failure.error, statusCode: failure.statusCode);
    }
  }

  /// Logout current user.
  /// 
  /// Removes token from storage.
  /// Does not call backend (backend token remains valid until expiry).
  Future<void> logout() async {
    await _tokenStore.clear();
  }

  /// Check if user is currently authenticated.
  /// 
  /// Returns true if a token exists in storage.
  /// Note: This does not validate the token with the backend.
  /// For v1, we assume token is valid if it exists.
  Future<bool> isAuthenticated() async {
    final token = await _tokenStore.getAccessToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Get stored access token (if any).
  /// 
  /// Returns the token string, or null if not logged in.
  Future<String?> getAccessToken() async {
    return _tokenStore.getAccessToken();
  }
}

