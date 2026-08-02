import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/lesson_videos.dart';
import '../../models/course_model.dart';
import '../../models/marketplace_model.dart';
import '../../models/hub_admin_model.dart';
import '../../models/user_model.dart';
import '../../models/publication_model.dart';
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
      onUpgrade: (db, oldVersion, newVersion) async {
        // Prototype: recreate seed data when schema/prices change.
        final tables = [
          'lesson_progress',
          'enrollments',
          'lessons',
          'course_modules',
          'quizzes',
          'ai_usage',
          'game_sessions',
          'educational_games',
          'job_applications',
          'job_postings',
          'service_bookings',
          'services',
          'room_bookings',
          'hub_rooms',
          'print_orders',
          'print_services',
          'user_reports',
          'contact_messages',
          'publications',
          'payment_logs',
          'admin_activity_logs',
          'courses',
          'gamification_wallets',
          'refresh_tokens',
          'users',
          'app_meta',
        ];
        for (final t in tables) {
          await db.execute('DROP TABLE IF EXISTS $t');
        }
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
      'status': 'active',
      'created_at': now,
    });
    await db.insert('gamification_wallets', {
      'user_id': id,
      'coins': 50,
      'xp': 0,
      'level': 1,
      'ai_token_bank': 3,
    });
    return AppUser(id: id, email: email, displayName: displayName, role: role, status: UserAccountStatus.active);
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
      aiTokenBank: (r['ai_token_bank'] as int?) ?? 0,
    );
  }

  Future<GamificationStats> awardRewards(String userId, {int coins = 0, int xp = 0}) async {
    final current = await getWallet(userId);
    final newXp = current.xp + xp;
    final newLevel = 1 + (newXp ~/ 300);
    await db.update(
      'gamification_wallets',
      {
        'coins': current.coins + coins,
        'xp': newXp,
        'level': newLevel,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return getWallet(userId);
  }

  Future<bool> spendCoins(String userId, int amount) async {
    final current = await getWallet(userId);
    if (current.coins < amount) return false;
    await db.update(
      'gamification_wallets',
      {'coins': current.coins - amount},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<RewardResult> completeLesson({
    required String userId,
    required String courseId,
    required String lessonId,
  }) async {
    final existing = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND lesson_id = ? AND completed = 1',
      whereArgs: [userId, lessonId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return const RewardResult(alreadyDone: true, message: 'Lesson already completed');
    }

    await enrollCourse(userId, courseId);
    await db.insert(
      'lesson_progress',
      {
        'user_id': userId,
        'lesson_id': lessonId,
        'completed': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Recalculate course progress
    final modules = await getCourseModules(courseId, userId: userId);
    final allLessons = modules.expand((m) => m.lessons).toList();
    final done = allLessons.where((l) => l.completed).length;
    final percent = allLessons.isEmpty ? 0.0 : (done / allLessons.length) * 100;
    await db.update(
      'enrollments',
      {'progress_percent': percent},
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );

    var coins = AppConfig.lessonCoinReward;
    var xp = AppConfig.lessonXpReward;
    if (percent >= 100) {
      coins += AppConfig.courseCompleteCoinBonus;
      xp += AppConfig.courseCompleteXpBonus;
    }

    await awardRewards(userId, coins: coins, xp: xp);
    return RewardResult(
      coins: coins,
      xp: xp,
      message: percent >= 100 ? 'Course completed!' : 'Lesson completed!',
    );
  }

  Future<bool> hasRewardedGameToday(String userId, String gameId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await db.query(
      'game_sessions',
      where: 'user_id = ? AND game_id = ? AND played_at LIKE ?',
      whereArgs: [userId, gameId, '$today%'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<RewardResult> completeGameSession({
    required String userId,
    required String gameId,
    required int scorePercent,
  }) async {
    final games = await getGames();
    EducationalGame? game;
    for (final g in games) {
      if (g.id == gameId) {
        game = g;
        break;
      }
    }
    if (game == null) {
      return const RewardResult(alreadyDone: true, message: 'Game not found');
    }

    final already = await hasRewardedGameToday(userId, gameId);
    final passed = scorePercent >= 60;
    var coins = 0;
    var xp = 0;
    if (passed && !already) {
      coins = game.coinReward;
      xp = game.xpReward;
      await awardRewards(userId, coins: coins, xp: xp);
    }

    await db.insert('game_sessions', {
      'id': 'gs_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'game_id': gameId,
      'score': scorePercent,
      'coins_earned': coins,
      'played_at': DateTime.now().toUtc().toIso8601String(),
    });

    if (!passed) {
      return const RewardResult(message: 'Score 60%+ to earn rewards');
    }
    if (already) {
      return const RewardResult(alreadyDone: true, message: 'Daily reward already claimed — nice practice!');
    }
    return RewardResult(coins: coins, xp: xp, message: 'Rewards unlocked!');
  }

  Future<AiQuota> getAiQuota(String userId) async {
    final used = await getAiUsageToday(userId);
    final wallet = await getWallet(userId);
    return AiQuota(
      freeUsed: used,
      freeLimit: AppConfig.aiDailyLimit,
      bank: wallet.aiTokenBank,
    );
  }

  /// Consumes free daily quota first, then bonus bank tokens.
  Future<bool> consumeAiToken(String userId, {int? freeLimit}) async {
    final used = await getAiUsageToday(userId);
    final limit = freeLimit ?? AppConfig.aiDailyLimit;
    final wallet = await getWallet(userId);
    final freeRemaining = (limit - used).clamp(0, limit);

    if (freeRemaining > 0) {
      await incrementAiUsage(userId);
      return true;
    }

    if (wallet.aiTokenBank <= 0) return false;
    await db.update(
      'gamification_wallets',
      {'ai_token_bank': wallet.aiTokenBank - 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<bool> unlockAiTokens({
    required String userId,
    required int coinCost,
    required int tokens,
  }) async {
    if (coinCost > 0) {
      final ok = await spendCoins(userId, coinCost);
      if (!ok) return false;
    }
    await creditAiTokens(userId, tokens);
    return true;
  }

  Future<void> creditAiTokens(String userId, int tokens) async {
    final wallet = await getWallet(userId);
    await db.update(
      'gamification_wallets',
      {'ai_token_bank': wallet.aiTokenBank + tokens},
      where: 'user_id = ?',
      whereArgs: [userId],
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
            .map((l) {
              final id = l['id'] as String;
              final storedVideo = l['video_path'] as String?;
              return Lesson(
                id: id,
                title: l['title'] as String,
                durationMinutes: l['duration_minutes'] as int,
                completed: completedLessons[id] ?? false,
                videoAsset: storedVideo ?? LessonVideos.assetFor(id),
              );
            })
            .toList(),
      ));
    }
    return modules;
  }

  Future<int> getEnrollmentCount(String userId) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM enrollments WHERE user_id = ?',
      [userId],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<void> enrollCourse(String userId, String courseId) async {
    await db.insert(
      'enrollments',
      {'user_id': userId, 'course_id': courseId, 'progress_percent': 0, 'bookmarked': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Course> createCourse({
    required String teacherId,
    required String title,
    required String description,
    required CourseCategory category,
    required Difficulty difficulty,
    required bool isFree,
    int? priceCents,
    int durationMinutes = 60,
    String? thumbnailUrl,
    String? introVideoPath,
  }) async {
    final id = 'course_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('courses', {
      'id': id,
      'teacher_id': teacherId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category.name,
      'difficulty': difficulty.name,
      'duration_minutes': durationMinutes,
      'skills': category.name,
      'is_free': isFree ? 1 : 0,
      'price_cents': isFree ? null : (priceCents ?? 0),
      'thumbnail_url': thumbnailUrl,
      'rating_avg': 5.0,
      'enrollment_count': 0,
    });

    final moduleId = 'mod_$id';
    await db.insert('course_modules', {
      'id': moduleId,
      'course_id': id,
      'title': 'Module 1',
      'sort_order': 0,
    });
    await db.insert('lessons', {
      'id': 'lesson_${id}_1',
      'module_id': moduleId,
      'title': 'Introduction',
      'duration_minutes': 15,
      'sort_order': 0,
      'video_path': introVideoPath,
    });

    await awardRewards(
      teacherId,
      coins: AppConfig.postCourseCoins,
      xp: AppConfig.postCourseXp,
    );

    final course = await getCourse(id, userId: teacherId);
    return course!;
  }

  Future<List<Course>> getCoursesByTeacher(String teacherId) async {
    final rows = await db.rawQuery('''
      SELECT c.*, u.display_name AS teacher_name
      FROM courses c
      JOIN users u ON u.id = c.teacher_id
      WHERE c.teacher_id = ?
      ORDER BY c.title ASC
    ''', [teacherId]);
    return rows.map((r) => _mapCourse(r)).toList();
  }

  Future<List<Course>> getEnrolledCourses(String userId) async {
    final rows = await db.rawQuery('''
      SELECT c.*, u.display_name AS teacher_name, e.progress_percent
      FROM enrollments e
      JOIN courses c ON c.id = e.course_id
      JOIN users u ON u.id = c.teacher_id
      WHERE e.user_id = ?
      ORDER BY e.progress_percent DESC, c.title ASC
    ''', [userId]);
    return rows.map((r) => _mapCourse(r, r['progress_percent'] as double?)).toList();
  }

  Future<List<FreelanceService>> getBookedServicesForClient(String clientId) async {
    final rows = await db.rawQuery('''
      SELECT s.*, u.display_name AS provider_name
      FROM services s
      JOIN users u ON u.id = s.provider_id
      WHERE s.id IN (
        SELECT service_id FROM service_bookings WHERE client_id = ?
      )
      ORDER BY s.title ASC
    ''', [clientId]);
    return rows.map(_mapService).toList();
  }

  Future<FreelanceService> createService({
    required String providerId,
    required String title,
    required String description,
    required String category,
    required int priceCents,
    int deliveryDays = 7,
  }) async {
    final id = 'svc_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('services', {
      'id': id,
      'provider_id': providerId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'price_cents': priceCents,
      'delivery_days': deliveryDays,
      'rating_avg': 5.0,
      'review_count': 0,
    });

    await awardRewards(
      providerId,
      coins: AppConfig.postServiceCoins,
      xp: AppConfig.postServiceXp,
    );

    final service = await getService(id);
    return service!;
  }

  Future<List<FreelanceService>> getServicesByProvider(String providerId) async {
    final rows = await db.rawQuery('''
      SELECT s.*, u.display_name AS provider_name
      FROM services s
      JOIN users u ON u.id = s.provider_id
      WHERE s.provider_id = ?
      ORDER BY s.title ASC
    ''', [providerId]);
    return rows.map(_mapService).toList();
  }

  /// Daily bonus for maintaining a strong rating (demo).
  Future<RewardResult> claimCreatorRatingBonus(String userId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'rating_bonus_$userId';
    final rows = await db.query('app_meta', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isNotEmpty && rows.first['value'] == today) {
      return const RewardResult(alreadyDone: true, message: 'Bonus already claimed today');
    }
    await db.insert(
      'app_meta',
      {'key': key, 'value': today},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await awardRewards(
      userId,
      coins: AppConfig.ratingBonusCoins,
      xp: AppConfig.ratingBonusXp,
    );
    return RewardResult(
      coins: AppConfig.ratingBonusCoins,
      xp: AppConfig.ratingBonusXp,
      message: 'Rating bonus claimed!',
    );
  }

  Future<void> awardBookingToProvider(String serviceId, {String? clientId}) async {
    final rows = await db.query('services', where: 'id = ?', whereArgs: [serviceId], limit: 1);
    if (rows.isEmpty) return;
    final providerId = rows.first['provider_id'] as String;
    final price = rows.first['price_cents'] as int;
    await awardRewards(
      providerId,
      coins: AppConfig.bookingReceivedCoins,
      xp: AppConfig.bookingReceivedXp,
    );
    if (clientId != null) {
      await db.insert('service_bookings', {
        'id': 'sb_${DateTime.now().millisecondsSinceEpoch}',
        'service_id': serviceId,
        'client_id': clientId,
        'provider_id': providerId,
        'total_cents': price,
        'status': 'confirmed',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  // ── Hub facilities (rooms + print) ────────────────────────────────

  Future<List<HubRoom>> getRooms({bool availableOnly = false}) async {
    final rows = await db.query(
      'hub_rooms',
      where: availableOnly ? 'available = 1' : null,
      orderBy: 'name ASC',
    );
    return rows.map(_mapRoom).toList();
  }

  Future<HubRoom?> getRoom(String id) async {
    final rows = await db.query('hub_rooms', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _mapRoom(rows.first);
  }

  Future<void> setRoomAvailability(String roomId, bool available) async {
    await db.update(
      'hub_rooms',
      {'available': available ? 1 : 0},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  Future<RoomBooking> bookRoom({
    required String roomId,
    required String userId,
    required String billing,
    required DateTime startAt,
    required DateTime endAt,
    int hours = 2,
  }) async {
    final room = await getRoom(roomId);
    if (room == null) throw StateError('Room not found');
    final total = billing == 'day'
        ? room.priceDayCents
        : room.priceHourCents * endAt.difference(startAt).inHours.clamp(1, 24);
    final id = 'rb_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('room_bookings', {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'billing': billing,
      'total_cents': total,
      'status': 'confirmed',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return RoomBooking(
      id: id,
      roomId: roomId,
      userId: userId,
      startAt: startAt.toIso8601String(),
      endAt: endAt.toIso8601String(),
      billing: billing,
      totalCents: total,
      status: 'confirmed',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      roomName: room.name,
    );
  }

  Future<List<RoomBooking>> getRoomBookings() async {
    final rows = await db.rawQuery('''
      SELECT b.*, r.name AS room_name, u.display_name AS user_name
      FROM room_bookings b
      JOIN hub_rooms r ON r.id = b.room_id
      JOIN users u ON u.id = b.user_id
      ORDER BY b.created_at DESC
    ''');
    return rows.map(_mapRoomBooking).toList();
  }

  Future<List<PrintServiceItem>> getPrintServices({bool activeOnly = true}) async {
    final rows = await db.query(
      'print_services',
      where: activeOnly ? 'active = 1' : null,
      orderBy: 'title ASC',
    );
    return rows.map(_mapPrintService).toList();
  }

  Future<PrintOrder> createPrintOrder({
    required String serviceId,
    required String userId,
    required int quantity,
    String? notes,
    DateTime? scheduledAt,
  }) async {
    final rows = await db.query('print_services', where: 'id = ?', whereArgs: [serviceId], limit: 1);
    if (rows.isEmpty) throw StateError('Print service not found');
    final price = rows.first['price_cents'] as int;
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'po_${DateTime.now().millisecondsSinceEpoch}';
    final total = price * quantity;
    await db.insert('print_orders', {
      'id': id,
      'service_id': serviceId,
      'user_id': userId,
      'quantity': quantity,
      'notes': notes,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'total_cents': total,
      'status': 'pending',
      'created_at': now,
    });
    return PrintOrder(
      id: id,
      serviceId: serviceId,
      userId: userId,
      quantity: quantity,
      notes: notes,
      totalCents: total,
      status: 'pending',
      createdAt: now,
      serviceTitle: rows.first['title'] as String,
    );
  }

  Future<List<PrintOrder>> getPrintOrders() async {
    final rows = await db.rawQuery('''
      SELECT o.*, p.title AS service_title, u.display_name AS user_name
      FROM print_orders o
      JOIN print_services p ON p.id = o.service_id
      JOIN users u ON u.id = o.user_id
      ORDER BY o.created_at DESC
    ''');
    return rows.map(_mapPrintOrder).toList();
  }

  Future<void> updatePrintOrderStatus(String id, String status) async {
    await db.update('print_orders', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Reports & contact ─────────────────────────────────────────────

  Future<UserReport> createReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'rep_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('user_reports', {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reason': reason,
      'details': details,
      'status': 'open',
      'created_at': now,
    });
    return UserReport(
      id: id,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reason: reason,
      details: details,
      status: 'open',
      createdAt: now,
    );
  }

  Future<List<UserReport>> getReports({String? status}) async {
    final rows = await db.rawQuery('''
      SELECT r.*,
        a.display_name AS reporter_name,
        b.display_name AS reported_name
      FROM user_reports r
      JOIN users a ON a.id = r.reporter_id
      JOIN users b ON b.id = r.reported_user_id
      ${status != null ? 'WHERE r.status = ?' : ''}
      ORDER BY r.created_at DESC
    ''', status != null ? [status] : []);
    return rows.map(_mapReport).toList();
  }

  Future<void> updateReportStatus(String id, String status) async {
    await db.update('user_reports', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<ContactMessage> createContactMessage({
    String? userId,
    required String name,
    required String email,
    required String subject,
    required String body,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('contact_messages', {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'subject': subject,
      'body': body,
      'status': 'new',
      'created_at': now,
    });
    return ContactMessage(
      id: id,
      userId: userId,
      name: name,
      email: email,
      subject: subject,
      body: body,
      status: 'new',
      createdAt: now,
    );
  }

  Future<List<ContactMessage>> getContactMessages() async {
    final rows = await db.query('contact_messages', orderBy: 'created_at DESC');
    return rows
        .map(
          (r) => ContactMessage(
            id: r['id'] as String,
            userId: r['user_id'] as String?,
            name: r['name'] as String,
            email: r['email'] as String,
            subject: r['subject'] as String,
            body: r['body'] as String,
            status: r['status'] as String,
            createdAt: r['created_at'] as String,
          ),
        )
        .toList();
  }

  Future<void> markContactRead(String id) async {
    await db.update('contact_messages', {'status': 'read'}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Admin ─────────────────────────────────────────────────────────

  Future<List<AppUser>> getAllUsers() async {
    final rows = await db.query('users', orderBy: 'created_at DESC');
    return rows.map(_mapUser).toList();
  }

  Future<List<AppUser>> searchUsers(String query, {String? excludeUserId}) async {
    if (query.trim().isEmpty) return [];
    final q = '%${query.trim().toLowerCase()}%';
    final rows = await db.query(
      'users',
      where: '''
        (LOWER(display_name) LIKE ? OR LOWER(email) LIKE ?)
        AND role != 'ADMIN'
        ${excludeUserId != null ? "AND id != ?" : ''}
      ''',
      whereArgs: excludeUserId != null ? [q, q, excludeUserId] : [q, q],
      orderBy: 'display_name ASC',
      limit: 25,
    );
    return rows.map(_mapUser).toList();
  }

  Future<List<FeaturedProvider>> getFeaturedProviders({int limit = 6}) async {
    final rows = await db.rawQuery('''
      SELECT u.id AS user_id, u.display_name, u.avatar_url,
             s.category, s.rating_avg, s.price_cents, s.title
      FROM services s
      JOIN users u ON u.id = s.provider_id
      WHERE u.role IN ('TEACHER', 'CLIENT')
      ORDER BY s.rating_avg DESC, s.review_count DESC
    ''');
    final seen = <String>{};
    final results = <FeaturedProvider>[];
    for (final row in rows) {
      final userId = row['user_id'] as String;
      if (seen.contains(userId)) continue;
      seen.add(userId);
      final category = row['category'] as String? ?? 'Freelancer';
      results.add(
        FeaturedProvider(
          userId: userId,
          displayName: row['display_name'] as String,
          headline: category,
          ratingAvg: (row['rating_avg'] as num).toDouble(),
          priceCents: row['price_cents'] as int,
          tags: [category, (row['title'] as String).split(' ').first],
          avatarUrl: row['avatar_url'] as String?,
        ),
      );
      if (results.length >= limit) break;
    }
    return results;
  }

  Future<List<FeaturedProvider>> getLearnProviders({int limit = 10}) async {
    final results = <FeaturedProvider>[];
    final seen = <String>{};

    final teacherRows = await db.rawQuery('''
      SELECT u.id AS user_id, u.display_name, u.avatar_url,
             MAX(c.rating_avg) AS rating_avg,
             MIN(c.price_cents) AS price_cents,
             GROUP_CONCAT(DISTINCT c.category) AS cats
      FROM users u
      INNER JOIN courses c ON c.teacher_id = u.id
      WHERE u.role = 'TEACHER'
      GROUP BY u.id
      ORDER BY rating_avg DESC
    ''');
    for (final row in teacherRows) {
      final userId = row['user_id'] as String;
      seen.add(userId);
      final cats = (row['cats'] as String?)?.split(',') ?? ['TEACHER'];
      results.add(
        FeaturedProvider(
          userId: userId,
          displayName: row['display_name'] as String,
          headline: cats.first,
          ratingAvg: (row['rating_avg'] as num).toDouble(),
          priceCents: (row['price_cents'] as int?) ?? 0,
          tags: cats.take(2).toList(),
          avatarUrl: row['avatar_url'] as String?,
        ),
      );
    }

    final freelancers = await getFeaturedProviders(limit: limit);
    for (final p in freelancers) {
      if (seen.contains(p.userId)) continue;
      seen.add(p.userId);
      results.add(p);
    }

    results.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    return results.take(limit).toList();
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    await db.update(
      'users',
      {'role': _roleToDb(role)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> setUserBlocked(String userId, bool blocked) async {
    await db.update(
      'users',
      {'status': blocked ? 'blocked' : 'active'},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
  }) async {
    final updates = <String, Object?>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (updates.isEmpty) return;
    await db.update('users', updates, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> deleteUser(String userId) async {
    await db.delete('gamification_wallets', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('refresh_tokens', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<List<ServiceBookingRecord>> getServiceBookings() async {
    final rows = await db.rawQuery('''
      SELECT b.*,
        s.title AS service_title,
        c.display_name AS client_name,
        p.display_name AS provider_name
      FROM service_bookings b
      JOIN services s ON s.id = b.service_id
      JOIN users c ON c.id = b.client_id
      JOIN users p ON p.id = b.provider_id
      ORDER BY b.created_at DESC
    ''');
    return rows.map(_mapServiceBooking).toList();
  }

  Future<AdminStats> getAdminStats() async {
    Future<int> count(String sql, [List<Object?>? args]) async {
      final r = await db.rawQuery(sql, args);
      return Sqflite.firstIntValue(r) ?? 0;
    }

    return AdminStats(
      learners: await count("SELECT COUNT(*) FROM users WHERE role = 'LEARNER'"),
      teachers: await count("SELECT COUNT(*) FROM users WHERE role = 'TEACHER'"),
      clients: await count("SELECT COUNT(*) FROM users WHERE role = 'CLIENT'"),
      courses: await count('SELECT COUNT(*) FROM courses'),
      services: await count('SELECT COUNT(*) FROM services'),
      serviceBookings: await count('SELECT COUNT(*) FROM service_bookings'),
      roomBookings: await count('SELECT COUNT(*) FROM room_bookings'),
      printOrders: await count('SELECT COUNT(*) FROM print_orders'),
      openReports: await count("SELECT COUNT(*) FROM user_reports WHERE status = 'open'"),
      newMessages: await count("SELECT COUNT(*) FROM contact_messages WHERE status = 'new'"),
      jobs: await count('SELECT COUNT(*) FROM job_postings'),
    );
  }

  Future<void> deleteCourse(String id) async {
    await db.delete('lessons', where: 'module_id IN (SELECT id FROM course_modules WHERE course_id = ?)', whereArgs: [id]);
    await db.delete('course_modules', where: 'course_id = ?', whereArgs: [id]);
    await db.delete('enrollments', where: 'course_id = ?', whereArgs: [id]);
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteService(String id) async {
    await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // ── Mappers (extended) ────────────────────────────────────────────

  HubRoom _mapRoom(Map<String, Object?> row) {
    final amenities = (row['amenities'] as String? ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return HubRoom(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      capacity: row['capacity'] as int,
      priceHourCents: row['price_hour_cents'] as int,
      priceDayCents: row['price_day_cents'] as int,
      available: (row['available'] as int) == 1,
      amenities: amenities,
    );
  }

  RoomBooking _mapRoomBooking(Map<String, Object?> row) {
    return RoomBooking(
      id: row['id'] as String,
      roomId: row['room_id'] as String,
      userId: row['user_id'] as String,
      startAt: row['start_at'] as String,
      endAt: row['end_at'] as String,
      billing: row['billing'] as String,
      totalCents: row['total_cents'] as int,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
      roomName: row['room_name'] as String?,
      userName: row['user_name'] as String?,
    );
  }

  PrintServiceItem _mapPrintService(Map<String, Object?> row) {
    return PrintServiceItem(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      priceCents: row['price_cents'] as int,
      unit: row['unit'] as String? ?? 'unit',
      active: (row['active'] as int?) != 0,
    );
  }

  PrintOrder _mapPrintOrder(Map<String, Object?> row) {
    return PrintOrder(
      id: row['id'] as String,
      serviceId: row['service_id'] as String,
      userId: row['user_id'] as String,
      quantity: row['quantity'] as int,
      notes: row['notes'] as String?,
      totalCents: row['total_cents'] as int,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
      serviceTitle: row['service_title'] as String?,
      userName: row['user_name'] as String?,
    );
  }

  UserReport _mapReport(Map<String, Object?> row) {
    return UserReport(
      id: row['id'] as String,
      reporterId: row['reporter_id'] as String,
      reportedUserId: row['reported_user_id'] as String,
      reason: row['reason'] as String,
      details: row['details'] as String?,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
      reporterName: row['reporter_name'] as String?,
      reportedName: row['reported_name'] as String?,
    );
  }

  ServiceBookingRecord _mapServiceBooking(Map<String, Object?> row) {
    return ServiceBookingRecord(
      id: row['id'] as String,
      serviceId: row['service_id'] as String,
      clientId: row['client_id'] as String,
      providerId: row['provider_id'] as String,
      totalCents: row['total_cents'] as int,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
      serviceTitle: row['service_title'] as String?,
      clientName: row['client_name'] as String?,
      providerName: row['provider_name'] as String?,
    );
  }

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
    final statusRaw = row['status'] as String? ?? 'active';
    return AppUser(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String,
      role: _parseRole(row['role'] as String),
      status: statusRaw == 'blocked' ? UserAccountStatus.blocked : UserAccountStatus.active,
      avatarUrl: row['avatar_url'] as String?,
      bio: row['bio'] as String?,
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
      thumbnailUrl: row['thumbnail_url'] as String?,
      ratingAvg: row['rating_avg'] as double,
      enrollmentCount: row['enrollment_count'] as int,
      progressPercent: progress,
      teacherName: row['teacher_name'] as String?,
      teacherId: row['teacher_id'] as String?,
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
      providerId: row['provider_id'] as String?,
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

  // ── Teacher enrollments ───────────────────────────────────────────

  Future<TeacherEnrollmentStats> getTeacherEnrollmentStats(String teacherId) async {
    final rows = await db.rawQuery('''
      SELECT u.id AS user_id, u.display_name, u.avatar_url, c.id AS course_id, c.title AS course_title,
             e.progress_percent
      FROM enrollments e
      JOIN courses c ON c.id = e.course_id
      JOIN users u ON u.id = e.user_id
      WHERE c.teacher_id = ?
      ORDER BY e.progress_percent DESC, u.display_name ASC
    ''', [teacherId]);
    final students = rows
        .map(
          (r) => EnrolledStudent(
            userId: r['user_id'] as String,
            displayName: r['display_name'] as String,
            courseId: r['course_id'] as String,
            courseTitle: r['course_title'] as String,
            progressPercent: (r['progress_percent'] as num).toDouble(),
            avatarUrl: r['avatar_url'] as String?,
          ),
        )
        .toList();
    final unique = <String>{};
    for (final s in students) {
      unique.add(s.userId);
    }
    return TeacherEnrollmentStats(totalStudents: unique.length, students: students);
  }

  Future<List<ContactMessage>> getUserMessages(String userId) async {
    final rows = await db.query(
      'contact_messages',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows
        .map(
          (r) => ContactMessage(
            id: r['id'] as String,
            userId: r['user_id'] as String?,
            name: r['name'] as String,
            email: r['email'] as String,
            subject: r['subject'] as String,
            body: r['body'] as String,
            status: r['status'] as String,
            createdAt: r['created_at'] as String,
          ),
        )
        .toList();
  }

  // ── Publications ──────────────────────────────────────────────────

  Future<List<Publication>> getPublications({String? hashtag, String? authorId}) async {
    final rows = await db.rawQuery('''
      SELECT p.*, u.display_name AS author_name
      FROM publications p
      JOIN users u ON u.id = p.author_id
      ORDER BY p.created_at DESC
    ''');
    var pubs = rows.map(_mapPublication).toList();
    if (authorId != null) {
      pubs = pubs.where((p) => p.authorId == authorId).toList();
    }
    if (hashtag != null && hashtag.isNotEmpty) {
      final tag = hashtag.startsWith('#') ? hashtag.toLowerCase() : '#${hashtag.toLowerCase()}';
      pubs = pubs.where((p) => p.hashtags.any((h) => h.toLowerCase() == tag)).toList();
    }
    return pubs;
  }

  Future<Publication> createPublication({
    required String authorId,
    required String body,
    List<String> hashtags = const [],
    List<String> imagePaths = const [],
    String kind = 'post',
  }) async {
    final id = 'pub_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toUtc().toIso8601String();
    final normalizedTags = hashtags
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .map((h) => h.startsWith('#') ? h : '#$h')
        .toList();
    await db.insert('publications', {
      'id': id,
      'author_id': authorId,
      'body': body.trim(),
      'hashtags': normalizedTags.join(','),
      'image_paths': imagePaths.join('|'),
      'kind': kind,
      'created_at': now,
    });
    final user = await findUserById(authorId);
    return Publication(
      id: id,
      authorId: authorId,
      authorName: user?.displayName ?? 'User',
      body: body.trim(),
      hashtags: normalizedTags,
      imagePaths: imagePaths,
      kind: kind,
      createdAt: now,
    );
  }

  // ── Admin logs ────────────────────────────────────────────────────

  Future<void> insertPaymentLog({
    required String? userId,
    required String? userName,
    required String purpose,
    required String title,
    required int amountCents,
    required String gateway,
    required String status,
    String? reference,
    String? itemId,
  }) async {
    await db.insert('payment_logs', {
      'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'user_name': userName,
      'purpose': purpose,
      'title': title,
      'amount_cents': amountCents,
      'gateway': gateway,
      'status': status,
      'reference': reference,
      'item_id': itemId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<PaymentLogRecord>> getPaymentLogs({int limit = 100}) async {
    final rows = await db.query(
      'payment_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_mapPaymentLog).toList();
  }

  Future<void> insertAdminActivityLog({
    required String? actorId,
    required String? actorName,
    required String action,
    String? targetType,
    String? targetId,
    String? details,
  }) async {
    await db.insert('admin_activity_logs', {
      'id': 'act_${DateTime.now().millisecondsSinceEpoch}',
      'actor_id': actorId,
      'actor_name': actorName,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'details': details,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<AdminActivityLog>> getAdminActivityLogs({int limit = 100}) async {
    final rows = await db.query(
      'admin_activity_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_mapAdminActivityLog).toList();
  }

  PaymentLogRecord _mapPaymentLog(Map<String, Object?> row) {
    return PaymentLogRecord(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      userName: row['user_name'] as String?,
      purpose: row['purpose'] as String,
      title: row['title'] as String,
      amountCents: row['amount_cents'] as int,
      gateway: row['gateway'] as String,
      status: row['status'] as String,
      reference: row['reference'] as String?,
      itemId: row['item_id'] as String?,
      createdAt: row['created_at'] as String,
    );
  }

  AdminActivityLog _mapAdminActivityLog(Map<String, Object?> row) {
    return AdminActivityLog(
      id: row['id'] as String,
      actorId: row['actor_id'] as String?,
      actorName: row['actor_name'] as String?,
      action: row['action'] as String,
      targetType: row['target_type'] as String?,
      targetId: row['target_id'] as String?,
      details: row['details'] as String?,
      createdAt: row['created_at'] as String,
    );
  }

  Publication _mapPublication(Map<String, Object?> row) {
    final tagsRaw = row['hashtags'] as String? ?? '';
    final imgsRaw = row['image_paths'] as String? ?? '';
    return Publication(
      id: row['id'] as String,
      authorId: row['author_id'] as String,
      authorName: row['author_name'] as String? ?? 'User',
      body: row['body'] as String,
      hashtags: tagsRaw.isEmpty ? const [] : tagsRaw.split(','),
      imagePaths: imgsRaw.isEmpty ? const [] : imgsRaw.split('|'),
      kind: row['kind'] as String? ?? 'post',
      createdAt: row['created_at'] as String,
    );
  }
}
