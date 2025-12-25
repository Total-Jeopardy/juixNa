import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/auth/model/auth_dtos.dart';

/// API client for authentication endpoints.
/// Uses the shared ApiClient for HTTP requests.
class AuthApi {
  final ApiClient _apiClient;

  AuthApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with email and password.
  /// 
  /// Endpoint: POST /api/auth/login
  /// 
  /// Backend expects OAuth2 format (form-encoded data):
  /// - username: (email value)
  /// - password: (password value)
  /// 
  /// Note: FastAPI OAuth2PasswordRequestForm uses 'username' field,
  /// even though we authenticate with email. The backend will look up
  /// the user by email using the username field value.
  /// 
  /// Response: { "access_token": "...", "token_type": "bearer", "user": {...} }
  /// 
  /// Returns ApiResult<LoginResponseDTO>:
  /// - Success: LoginResponseDTO with token and user data
  /// - Failure: ApiError with message and type (unauthorized, validation, etc.)
  Future<ApiResult<LoginResponseDTO>> login({
    required String email,
    required String password,
  }) async {
    // FastAPI OAuth2PasswordRequestForm expects form-encoded data
    // with 'username' field (even though we use email for authentication)
    final formData = {
      'username': email.trim(), // OAuth2 standard uses 'username' field
      'password': password,
    };

    print('🔵 AuthApi.login() called');
    print('   Email (as username): ${email.trim()}');
    print('   Password: ${password.length > 0 ? '***' : '(empty)'}');

    final result = await _apiClient.post<LoginResponseDTO>(
      '/api/auth/login',
      body: formData,
      useFormData: true, // Form-encoded data (OAuth2 format)
      parse: (json) => LoginResponseDTO.fromJson(json as Map<String, dynamic>),
    );

    // Log the result
    if (result.isSuccess) {
      print('✅ Login successful');
    } else {
      final failure = result as ApiFailure<LoginResponseDTO>;
      print('❌ Login failed:');
      print('   Error type: ${failure.error.type}');
      print('   Error message: ${failure.error.message}');
      print('   Status code: ${failure.statusCode}');
      print('   Details: ${failure.error.details}');
    }

    return result;
  }
}

