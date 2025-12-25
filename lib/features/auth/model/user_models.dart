import 'auth_dtos.dart';

/// Domain model for authenticated user.
/// Converted from UserDTO after successful login.
class User {
  final int id;
  final String email;
  final String name;
  final List<String> roles;
  final List<String> permissions;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.roles,
    required this.permissions,
  });

  /// Convert from DTO (after successful login).
  factory User.fromDTO(UserDTO dto) {
    return User(
      id: dto.id,
      email: dto.email,
      name: dto.name,
      roles: List<String>.from(dto.roles),
      permissions: List<String>.from(dto.permissions),
    );
  }

  /// Check if user has a specific role (case-insensitive).
  /// Example: user.hasRole("manager") or user.hasRole("Manager")
  bool hasRole(String role) {
    final lowerRole = role.toLowerCase();
    return roles.any((r) => r.toLowerCase() == lowerRole);
  }

  /// Check if user has any of the specified roles (case-insensitive).
  /// Example: user.hasAnyRole(["manager", "admin"])
  bool hasAnyRole(List<String> rolesToCheck) {
    final lowerRoles = rolesToCheck.map((r) => r.toLowerCase()).toList();
    return roles.any((role) => lowerRoles.contains(role.toLowerCase()));
  }

  /// Check if user has a specific permission (case-insensitive).
  /// Permissions are in format: "module.action"
  /// Example: user.hasPermission("inventory.view")
  bool hasPermission(String permission) {
    final lowerPermission = permission.toLowerCase();
    return permissions.any((perm) => perm.toLowerCase() == lowerPermission);
  }

  /// Check if user has any of the specified permissions (case-insensitive).
  /// Example: user.hasAnyPermission(["inventory.view", "inventory.stock_in"])
  bool hasAnyPermission(List<String> permissionsToCheck) {
    final lowerPermissions = permissionsToCheck.map((p) => p.toLowerCase()).toList();
    return permissions.any((perm) => lowerPermissions.contains(perm.toLowerCase()));
  }

  /// Check if user has all of the specified permissions (case-insensitive).
  /// Example: user.hasAllPermissions(["inventory.view", "inventory.stock_in"])
  bool hasAllPermissions(List<String> permissionsToCheck) {
    final lowerPermissions = permissionsToCheck.map((p) => p.toLowerCase()).toList();
    final userLowerPermissions = permissions.map((p) => p.toLowerCase()).toList();
    return lowerPermissions.every((perm) => userLowerPermissions.contains(perm));
  }

  /// Check if user is an admin (has "admin" role or admin.* permissions).
  /// Case-insensitive role check.
  bool get isAdmin {
    return hasRole('admin') ||
        permissions.any((perm) => perm.toLowerCase().startsWith('admin.'));
  }

  /// Check if user is a manager (has "manager" role).
  /// Case-insensitive role check.
  bool get isManager {
    return hasRole('manager');
  }

  /// Get display name (falls back to email if name is empty).
  String get displayName {
    return name.trim().isNotEmpty ? name : email;
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $name, roles: $roles)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

