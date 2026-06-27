import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/marketplace_model.dart';
import '../services/auth_repository.dart';
import 'database_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

const _sessionKey = 'smooth_auth_session';

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final AuthSession? session;
  final bool isLoading;
  final String? error;

  AppUser? get user => session?.user;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _restore();
  }

  final AuthRepository _repo;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw != null) {
      try {
        var session = AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        final freshUser = await _repo.refreshUser(session.user.id);
        if (freshUser != null) {
          session = AuthSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: freshUser,
          );
          await _persist(session);
        }
        state = AuthState(status: AuthStatus.authenticated, session: session);
        return;
      } catch (_) {
        await prefs.remove(_sessionKey);
      }
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _persist(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode({
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'user': {
        'id': session.user.id,
        'email': session.user.email,
        'displayName': session.user.displayName,
        'role': session.user.roleLabel,
        'avatarUrl': session.user.avatarUrl,
      },
    }));
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repo.register(
        email: email.trim().toLowerCase(),
        password: password,
        displayName: displayName.trim(),
        role: role,
      );
      await _persist(session);
      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repo.login(email: email, password: password);
      await _persist(session);
      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final gamificationProvider = FutureProvider<GamificationStats>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return const GamificationStats();
  return ref.watch(databaseProvider).getWallet(userId);
});

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  return ref.watch(databaseProvider).getCourses(userId: userId);
});

final courseProvider = FutureProvider.family<Course?, String>((ref, id) async {
  final userId = ref.watch(authProvider).user?.id;
  return ref.watch(databaseProvider).getCourse(id, userId: userId);
});

final courseModulesProvider =
    FutureProvider.family<List<CourseModule>, String>((ref, courseId) async {
  final userId = ref.watch(authProvider).user?.id;
  return ref.watch(databaseProvider).getCourseModules(courseId, userId: userId);
});

final servicesProvider = FutureProvider<List<FreelanceService>>((ref) async {
  return ref.watch(databaseProvider).getServices();
});

final serviceProvider = FutureProvider.family<FreelanceService?, String>((ref, id) async {
  return ref.watch(databaseProvider).getService(id);
});

final jobsProvider = FutureProvider.family<List<JobPosting>, bool?>((ref, remoteOnly) async {
  return ref.watch(databaseProvider).getJobs(remoteOnly: remoteOnly);
});

final gamesProvider = FutureProvider<List<EducationalGame>>((ref) async {
  return ref.watch(databaseProvider).getGames();
});

final searchProvider = FutureProvider.family<
    ({List<Course> courses, List<FreelanceService> services, List<JobPosting> jobs}),
    String>((ref, query) async {
  final userId = ref.watch(authProvider).user?.id;
  return ref.watch(databaseProvider).search(query, userId: userId);
});

final aiUsageProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return 0;
  return ref.watch(databaseProvider).getAiUsageToday(userId);
});
