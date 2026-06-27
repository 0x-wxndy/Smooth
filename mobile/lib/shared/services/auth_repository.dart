import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../data/database/app_database.dart';
import '../data/database/database_seeder.dart';
import '../providers/database_provider.dart';

class AuthRepository {
  AuthRepository(this._db);

  final AppDatabase _db;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final existing = await _db.findUserByEmail(email);
    if (existing != null) {
      throw Exception('Email already registered');
    }

    final user = await _db.createUser(
      email: email,
      passwordHash: DatabaseSeeder.hashPassword(password),
      displayName: displayName,
      role: role,
    );

    return AuthSession(
      accessToken: 'local_${user.id}',
      refreshToken: 'local_refresh_${user.id}',
      user: user,
    );
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final valid = await _db.verifyPassword(email, password);
    if (!valid) {
      throw Exception('Invalid email or password');
    }
    final user = await _db.findUserByEmail(email);
    if (user == null) throw Exception('User not found');

    return AuthSession(
      accessToken: 'local_${user.id}',
      refreshToken: 'local_refresh_${user.id}',
      user: user,
    );
  }

  Future<AppUser?> refreshUser(String id) => _db.findUserById(id);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(databaseProvider));
});
