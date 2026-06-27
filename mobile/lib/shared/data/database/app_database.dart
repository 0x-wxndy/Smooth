import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/config/app_config.dart';
import '../../models/course_model.dart';
import '../../models/marketplace_model.dart';
import '../../models/user_model.dart';
import 'database_schema.dart';
import 'database_seeder.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.dbName);
    _db = await openDatabase(
      path,
      version: AppConfig.dbVersion,
      onCreate: (db, version) async {
        for (final sql in DatabaseSchema.all) {
          await db.execute(sql);
        }
        await DatabaseSeeder.seedIfNeeded(db);
      },
    );
    await DatabaseSeeder.seedIfNeeded(_db!);
  }

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('AppDatabase not initialized. Call init() first.');
    }
    return database;
  }

  // ── Auth ──────────────────────────────────────────────────────────

  Future<AppUser?> findUserByEmail(String email) async {
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapUser(rows.first);
  }

  Future<AppUser?> findUserById(String id) async {
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _mapUser(rows.first);
  }

  Future<AppUser> createUser({
    required String email,
    required String passwordHash,
    required String displayName,
    required UserRole role,
  }) async {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('users', {
      'id': id,
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'display_name': displayName,
      'role': _roleToDb(role),
      'created_at': now,
    });
    await db.insert('gamification_wallets', {
      'user_id': id,
      'coins': 50,
      'xp': 0,
      'level': 1,
    });
    return AppUser(id: id, email: email, displayName: displayName, role: role);
  }

  Future<bool> verifyPassword(String email, String password) async {
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return rows.first['password_hash'] == DatabaseSeeder.hashPassword(password);
  }

  // ── Gamification ──────────────────────────────────────────────────

  Future<GamificationStats> getWallet(String userId) async {
    final rows = await db.query(
      'gamification_wallets',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return const GamificationStats();
    final r = rows.first;
    return GamificationStats(
      coins: r['coins'] as int,
      xp: r['xp'] as int,
      level: r['level'] as int,
      currentStreak: r['current_streak'] as int,
      longestStreak: r['longest_streak'] as int,
    );
  }

  // ── Courses ───────────────────────────────────────────────────────

  Future<List<Course>> getCourses({String? userId}) async {
    final rows = await db.rawQuery('''
      SELECT c.*, u.display_name AS teacher_name
      FROM courses c
      JOIN users u ON u.id = c.teacher_id
      ORDER BY c.enrollment_count DESC
    ''');

    final enrollments = userId != null
        ? {
            for (final e in await db.query('enrollments', where: 'user_id = ?', whereArgs: [userId]))
              e['course_id'] as String: e['progress_percent'] as double,
          }
        : <String, double>{};

    return rows.map((r) => _mapCourse(r, enrollments[r['id'] as String])).toList();
  }

  Future<Course?> getCourse(String id, {String? userId}) async {
    final rows = await db.rawQuery('''
      SELECT c.*, u.display_name AS teacher_name
      FROM courses c
      JOIN users u ON u.id = c.teacher_id
      WHERE c.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    double? progress;
    if (userId != null) {
      final e = await db.query(
        'enrollments',
        where: 'user_id = ? AND course_id = ?',
        whereArgs: [userId, id],
        limit: 1,
      );
      if (e.isNotEmpty) progress = e.first['progress_percent'] as double;
    }
    return _mapCourse(rows.first, progress);
  }

  Future<List<CourseModule>> getCourseModules(String courseId, {String? userId}) async {
    final modRows = await db.query(
      'course_modules',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'sort_order ASC',
    );

    final completedLessons = userId != null
        ? {
            for (final p in await db.query('lesson_progress', where: 'user_id = ? AND completed = 1', whereArgs: [userId]))
              p['lesson_id'] as String: true,
          }
        : <String, bool>{};

    final modules = <CourseModule>[];
    for (final mod in modRows) {
      final lessonRows = await db.query(
        'lessons',
        where: 'module_id = ?',
        whereArgs: [mod['id']],
        orderBy: 'sort_order ASC',
      );
      modules.add(CourseModule(
        id: mod['id'] as String,
        title: mod['title'] as String,
        lessons: lessonRows
            .map((l) => Lesson(
                  id: l['id'] as String,
                  title: l['title'] as String,
                  durationMinutes: l['duration_minutes'] as int,
                  completed: completedLessons[l['id'] as String] ?? false,
                ))
            .toList(),
      ));
    }
    return modules;
  }

  Future<void> enrollCourse(String userId, String courseId) async {
    await db.insert(
      'enrollments',
      {'user_id': userId, 'course_id': courseId, 'progress_percent': 0, 'bookmarked': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // ── Marketplace ───────────────────────────────────────────────────

  Future<List<FreelanceService>> getServices() async {
    final rows = await db.rawQuery('''
      SELECT s.*, u.display_name AS provider_name
      FROM services s
      JOIN users u ON u.id = s.provider_id
      ORDER BY s.rating_avg DESC
    ''');
    return rows.map(_mapService).toList();
  }

  Future<FreelanceService?> getService(String id) async {
    final rows = await db.rawQuery('''
      SELECT s.*, u.display_name AS provider_name
      FROM services s
      JOIN users u ON u.id = s.provider_id
      WHERE s.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return _mapService(rows.first);
  }

  // ── Jobs ──────────────────────────────────────────────────────────

  Future<List<JobPosting>> getJobs({bool? remoteOnly}) async {
    final rows = await db.query(
      'job_postings',
      where: remoteOnly == true ? 'remote = 1' : null,
      orderBy: 'title ASC',
    );
    return rows.map(_mapJob).toList();
  }

  // ── Games ─────────────────────────────────────────────────────────

  Future<List<EducationalGame>> getGames() async {
    final rows = await db.query('educational_games', orderBy: 'title ASC');
    return rows
        .map((r) => EducationalGame(
              id: r['id'] as String,
              title: r['title'] as String,
              description: r['description'] as String,
              category: r['category'] as String,
              coinReward: r['coin_reward'] as int,
              xpReward: r['xp_reward'] as int,
            ))
        .toList();
  }

  // ── Search ────────────────────────────────────────────────────────

  Future<({List<Course> courses, List<FreelanceService> services, List<JobPosting> jobs})> search(
    String query, {
    String? userId,
  }) async {
    if (query.trim().isEmpty) {
      return (courses: <Course>[], services: <FreelanceService>[], jobs: <JobPosting>[]);
    }
    final q = '%${query.trim()}%';

    final courseRows = await db.rawQuery('''
      SELECT c.*, u.display_name AS teacher_name
      FROM courses c JOIN users u ON u.id = c.teacher_id
      WHERE c.title LIKE ? OR c.description LIKE ?
    ''', [q, q]);

    final serviceRows = await db.rawQuery('''
      SELECT s.*, u.display_name AS provider_name
      FROM services s JOIN users u ON u.id = s.provider_id
      WHERE s.title LIKE ? OR s.description LIKE ?
    ''', [q, q]);

    final jobRows = await db.query(
      'job_postings',
      where: 'title LIKE ? OR company_name LIKE ?',
      whereArgs: [q, q],
    );

    final enrollments = userId != null
        ? {
            for (final e in await db.query('enrollments', where: 'user_id = ?', whereArgs: [userId]))
              e['course_id'] as String: e['progress_percent'] as double,
          }
        : <String, double>{};

    return (
      courses: courseRows.map((r) => _mapCourse(r, enrollments[r['id'] as String])).toList(),
      services: serviceRows.map(_mapService).toList(),
      jobs: jobRows.map(_mapJob).toList(),
    );
  }

  // ── AI usage ──────────────────────────────────────────────────────

  Future<int> getAiUsageToday(String userId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await db.query(
      'ai_usage',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, today],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return rows.first['interactions_count'] as int;
  }

  Future<int> incrementAiUsage(String userId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final current = await getAiUsageToday(userId);
    await db.insert(
      'ai_usage',
      {'user_id': userId, 'date': today, 'interactions_count': current + 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return current + 1;
  }

  // ── Mappers ───────────────────────────────────────────────────────

  AppUser _mapUser(Map<String, Object?> row) {
    return AppUser(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String,
      role: _parseRole(row['role'] as String),
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  Course _mapCourse(Map<String, Object?> row, [double? progress]) {
    return Course(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      category: _parseCategory(row['category'] as String),
      difficulty: _parseDifficulty(row['difficulty'] as String),
      durationMinutes: row['duration_minutes'] as int,
      skills: (row['skills'] as String).split(','),
      isFree: (row['is_free'] as int) == 1,
      priceCents: row['price_cents'] as int?,
      ratingAvg: row['rating_avg'] as double,
      enrollmentCount: row['enrollment_count'] as int,
      progressPercent: progress,
      teacherName: row['teacher_name'] as String?,
    );
  }

  FreelanceService _mapService(Map<String, Object?> row) {
    return FreelanceService(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      priceCents: row['price_cents'] as int,
      deliveryDays: row['delivery_days'] as int,
      ratingAvg: row['rating_avg'] as double,
      reviewCount: row['review_count'] as int,
      providerName: row['provider_name'] as String?,
      category: row['category'] as String?,
    );
  }

  JobPosting _mapJob(Map<String, Object?> row) {
    return JobPosting(
      id: row['id'] as String,
      title: row['title'] as String,
      companyName: row['company_name'] as String,
      type: row['type'] as String,
      remote: (row['remote'] as int) == 1,
      location: row['location'] as String?,
      salaryMin: row['salary_min'] as int?,
      salaryMax: row['salary_max'] as int?,
      experienceLevel: row['experience_level'] as String?,
    );
  }

  UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
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

  String _roleToDb(UserRole role) {
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

  CourseCategory _parseCategory(String value) {
    return CourseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => CourseCategory.other,
    );
  }

  Difficulty _parseDifficulty(String value) {
    return Difficulty.values.firstWhere(
      (d) => d.name == value,
      orElse: () => Difficulty.beginner,
    );
  }
}
