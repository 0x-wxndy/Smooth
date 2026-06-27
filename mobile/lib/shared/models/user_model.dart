enum UserRole { learner, teacher, client, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: _parseRole(json['role'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'TEACHER':
        return UserRole.teacher;
      case 'CLIENT':
        return UserRole.client;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.learner;
    }
  }

  String get roleLabel {
    switch (role) {
      case UserRole.learner:
        return 'LEARNER';
      case UserRole.teacher:
        return 'TEACHER';
      case UserRole.client:
        return 'CLIENT';
      case UserRole.admin:
        return 'ADMIN';
    }
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
