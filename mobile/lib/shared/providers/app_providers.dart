import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/marketplace_model.dart';
import '../models/hub_admin_model.dart';
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

final featuredProvidersProvider = FutureProvider<List<FeaturedProvider>>((ref) async {
  return ref.watch(databaseProvider).getFeaturedProviders();
});

final learnProvidersProvider = FutureProvider<List<FeaturedProvider>>((ref) async {
  return ref.watch(databaseProvider).getLearnProviders();
});

final providerStatsProvider =
    FutureProvider.family<({double ratingAvg, int reviewCount}), String>((ref, userId) async {
  final db = ref.watch(databaseProvider);
  final services = await db.getServicesByProvider(userId);
  if (services.isNotEmpty) {
    final rating = services.map((s) => s.ratingAvg).reduce((a, b) => a + b) / services.length;
    final reviews = services.map((s) => s.reviewCount).reduce((a, b) => a + b);
    return (ratingAvg: rating, reviewCount: reviews);
  }
  final courses = await db.getCoursesByTeacher(userId);
  if (courses.isNotEmpty) {
    final rating = courses.map((c) => c.ratingAvg).reduce((a, b) => a + b) / courses.length;
    final reviews = courses.fold<int>(0, (sum, c) => sum + (c.enrollmentCount ~/ 3).clamp(8, 120));
    return (ratingAvg: rating, reviewCount: reviews);
  }
  return (ratingAvg: 4.8, reviewCount: 12);
});

final jobsProvider = FutureProvider.family<List<JobPosting>, bool?>((ref, remoteOnly) async {
  return ref.watch(databaseProvider).getJobs(remoteOnly: remoteOnly);
});

final gamesProvider = FutureProvider<List<EducationalGame>>((ref) async {
  return ref.watch(databaseProvider).getGames();
});

final myCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(databaseProvider).getCoursesByTeacher(user.id);
});

final myServicesProvider = FutureProvider<List<FreelanceService>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(databaseProvider).getServicesByProvider(user.id);
});

final enrolledCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(databaseProvider).getEnrolledCourses(user.id);
});

final bookedServicesProvider = FutureProvider<List<FreelanceService>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return ref.watch(databaseProvider).getBookedServicesForClient(user.id);
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

final aiQuotaProvider = FutureProvider<AiQuota>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) {
    return const AiQuota(freeUsed: 0, freeLimit: AppConfig.aiDailyLimit, bank: 0);
  }
  return ref.watch(databaseProvider).getAiQuota(userId);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.watch(databaseProvider).getAdminStats();
});

final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  return ref.watch(databaseProvider).getAllUsers();
});

final reportsProvider = FutureProvider<List<UserReport>>((ref) async {
  return ref.watch(databaseProvider).getReports();
});

final contactMessagesProvider = FutureProvider<List<ContactMessage>>((ref) async {
  return ref.watch(databaseProvider).getContactMessages();
});

final userMessagesProvider = FutureProvider<List<ContactMessage>>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(databaseProvider).getUserMessages(userId);
});

final roomsProvider = FutureProvider<List<HubRoom>>((ref) async {
  return ref.watch(databaseProvider).getRooms();
});

final roomBookingsProvider = FutureProvider<List<RoomBooking>>((ref) async {
  return ref.watch(databaseProvider).getRoomBookings();
});

final printServicesProvider = FutureProvider<List<PrintServiceItem>>((ref) async {
  return ref.watch(databaseProvider).getPrintServices();
});

final printOrdersProvider = FutureProvider<List<PrintOrder>>((ref) async {
  return ref.watch(databaseProvider).getPrintOrders();
});

final serviceBookingsProvider = FutureProvider<List<ServiceBookingRecord>>((ref) async {
  return ref.watch(databaseProvider).getServiceBookings();
});
