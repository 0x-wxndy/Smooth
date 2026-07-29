enum UserRole { learner, teacher, client, admin }

enum UserAccountStatus { active, blocked }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.status = UserAccountStatus.active,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final UserAccountStatus status;
  final String? avatarUrl;
  final String? bio;

  bool get isBlocked => status == UserAccountStatus.blocked;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: _parseRole(json['role'] as String?),
      status: _parseStatus(json['status'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
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

  static UserAccountStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'blocked':
        return UserAccountStatus.blocked;
      default:
        return UserAccountStatus.active;
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

  AppUser copyWith({
    String? displayName,
    UserAccountStatus? status,
    String? bio,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role,
      status: status ?? this.status,
      avatarUrl: avatarUrl,
      bio: bio ?? this.bio,
    );
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
