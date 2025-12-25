/// Data Transfer Objects for authentication API requests and responses.
/// These match the backend API contract exactly.

/// Request DTO for login endpoint.
class LoginRequestDTO {
  final String email;
  final String password;

  const LoginRequestDTO({required this.email, required this.password});

  /// Convert to JSON for API request.
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Response DTO for login endpoint.
/// Matches backend response: { access_token, token_type, user }
class LoginResponseDTO {
  final String accessToken;
  final String tokenType;
  final UserDTO user;

  const LoginResponseDTO({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  /// Parse from JSON response.
  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// User data from login response.
/// Matches backend user object: { id, email, name, roles, permissions }
class UserDTO {
  final int id;
  final String email;
  final String name;
  final List<String> roles;
  final List<String> permissions;

  const UserDTO({
    required this.id,
    required this.email,
    required this.name,
    required this.roles,
    required this.permissions,
  });

  /// Parse from JSON response.
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    // Handle roles - could be List<String> or List<dynamic>
    final rolesData = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesData.map((e) => e.toString()).toList();

    // Handle permissions - could be List<String> or List<dynamic>
    final permissionsData = json['permissions'] as List<dynamic>? ?? [];
    final permissions = permissionsData.map((e) => e.toString()).toList();

    return UserDTO(
      id: json['id'] as int? ?? 0, // Handle null id
      email: json['email'] as String? ?? '', // Handle null email
      name: json['name'] as String? ?? '', // Handle null name
      roles: roles,
      permissions: permissions,
    );
  }

  /// Convert to JSON (for storage/caching if needed).
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'roles': roles,
    'permissions': permissions,
  };
}
