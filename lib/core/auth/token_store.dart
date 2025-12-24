import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores and retrieves auth tokens securely on device.
/// Used by ApiClient via tokenProvider.
class TokenStore {
  static const _keyAccessToken = 'juixna_access_token';

  final FlutterSecureStorage _storage;

  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Save token after login
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Read token for API calls
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Remove token on logout or when token is invalid
  Future<void> clear() async {
    await _storage.delete(key: _keyAccessToken);
  }
}
