abstract final class DatabaseSchema {
  static const users = '''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      display_name TEXT NOT NULL,
      role TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      avatar_url TEXT,
      bio TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const wallets = '''
    CREATE TABLE gamification_wallets (
      user_id TEXT PRIMARY KEY,
      coins INTEGER NOT NULL DEFAULT 0,
      xp INTEGER NOT NULL DEFAULT 0,
      level INTEGER NOT NULL DEFAULT 1,
      current_streak INTEGER NOT NULL DEFAULT 0,
      longest_streak INTEGER NOT NULL DEFAULT 0,
      last_login_date TEXT,
      ai_token_bank INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';

  static const courses = '''
    CREATE TABLE courses (
      id TEXT PRIMARY KEY,
      teacher_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      duration_minutes INTEGER NOT NULL,
      skills TEXT NOT NULL,
      is_free INTEGER NOT NULL DEFAULT 1,
      price_cents INTEGER,
      thumbnail_url TEXT,
      rating_avg REAL NOT NULL DEFAULT 0,
      enrollment_count INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (teacher_id) REFERENCES users(id)
    )
  ''';

  static const modules = '''
    CREATE TABLE course_modules (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL,
      title TEXT NOT NULL,
      sort_order INTEGER NOT NULL,
      FOREIGN KEY (course_id) REFERENCES courses(id)
    )
  ''';

  static const lessons = '''
    CREATE TABLE lessons (
      id TEXT PRIMARY KEY,
      module_id TEXT NOT NULL,
      title TEXT NOT NULL,
      duration_minutes INTEGER NOT NULL,
      sort_order INTEGER NOT NULL,
      video_path TEXT,
      FOREIGN KEY (module_id) REFERENCES course_modules(id)
    )
  ''';

  static const enrollments = '''
    CREATE TABLE enrollments (
      user_id TEXT NOT NULL,
      course_id TEXT NOT NULL,
      progress_percent REAL NOT NULL DEFAULT 0,
      bookmarked INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, course_id),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (course_id) REFERENCES courses(id)
    )
  ''';

  static const lessonProgress = '''
    CREATE TABLE lesson_progress (
      user_id TEXT NOT NULL,
      lesson_id TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, lesson_id),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (lesson_id) REFERENCES lessons(id)
    )
  ''';

  static const services = '''
    CREATE TABLE services (
      id TEXT PRIMARY KEY,
      provider_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      price_cents INTEGER NOT NULL,
      delivery_days INTEGER NOT NULL,
      rating_avg REAL NOT NULL DEFAULT 0,
      review_count INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (provider_id) REFERENCES users(id)
    )
  ''';

  static const jobs = '''
    CREATE TABLE job_postings (
      id TEXT PRIMARY KEY,
      company_name TEXT NOT NULL,
      title TEXT NOT NULL,
      type TEXT NOT NULL,
      remote INTEGER NOT NULL DEFAULT 0,
      location TEXT,
      salary_min INTEGER,
      salary_max INTEGER,
      experience_level TEXT,
      description TEXT NOT NULL
    )
  ''';

  static const games = '''
    CREATE TABLE educational_games (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      coin_reward INTEGER NOT NULL DEFAULT 5,
      xp_reward INTEGER NOT NULL DEFAULT 10
    )
  ''';

  static const gameSessions = '''
    CREATE TABLE game_sessions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      game_id TEXT NOT NULL,
      score INTEGER NOT NULL DEFAULT 0,
      coins_earned INTEGER NOT NULL DEFAULT 0,
      played_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (game_id) REFERENCES educational_games(id)
    )
  ''';

  static const aiUsage = '''
    CREATE TABLE ai_usage (
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      interactions_count INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, date),
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';

  static const meta = '''
    CREATE TABLE app_meta (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const rooms = '''
    CREATE TABLE hub_rooms (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      capacity INTEGER NOT NULL DEFAULT 10,
      price_hour_cents INTEGER NOT NULL,
      price_day_cents INTEGER NOT NULL,
      available INTEGER NOT NULL DEFAULT 1,
      amenities TEXT NOT NULL DEFAULT ''
    )
  ''';

  static const roomBookings = '''
    CREATE TABLE room_bookings (
      id TEXT PRIMARY KEY,
      room_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      start_at TEXT NOT NULL,
      end_at TEXT NOT NULL,
      billing TEXT NOT NULL,
      total_cents INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'confirmed',
      created_at TEXT NOT NULL,
      FOREIGN KEY (room_id) REFERENCES hub_rooms(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';

  static const printServices = '''
    CREATE TABLE print_services (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      price_cents INTEGER NOT NULL,
      unit TEXT NOT NULL DEFAULT 'unit',
      active INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const printOrders = '''
    CREATE TABLE print_orders (
      id TEXT PRIMARY KEY,
      service_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      scheduled_at TEXT,
      total_cents INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      FOREIGN KEY (service_id) REFERENCES print_services(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';

  static const serviceBookings = '''
    CREATE TABLE service_bookings (
      id TEXT PRIMARY KEY,
      service_id TEXT NOT NULL,
      client_id TEXT NOT NULL,
      provider_id TEXT NOT NULL,
      total_cents INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'confirmed',
      created_at TEXT NOT NULL,
      FOREIGN KEY (service_id) REFERENCES services(id),
      FOREIGN KEY (client_id) REFERENCES users(id),
      FOREIGN KEY (provider_id) REFERENCES users(id)
    )
  ''';

  static const userReports = '''
    CREATE TABLE user_reports (
      id TEXT PRIMARY KEY,
      reporter_id TEXT NOT NULL,
      reported_user_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      details TEXT,
      status TEXT NOT NULL DEFAULT 'open',
      created_at TEXT NOT NULL,
      FOREIGN KEY (reporter_id) REFERENCES users(id),
      FOREIGN KEY (reported_user_id) REFERENCES users(id)
    )
  ''';

  static const contactMessages = '''
    CREATE TABLE contact_messages (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      subject TEXT NOT NULL,
      body TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'new',
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';

  static const publications = '''
    CREATE TABLE publications (
      id TEXT PRIMARY KEY,
      author_id TEXT NOT NULL,
      body TEXT NOT NULL,
      hashtags TEXT NOT NULL DEFAULT '',
      image_paths TEXT NOT NULL DEFAULT '',
      kind TEXT NOT NULL DEFAULT 'post',
      created_at TEXT NOT NULL,
      FOREIGN KEY (author_id) REFERENCES users(id)
    )
  ''';

  static const paymentLogs = '''
    CREATE TABLE payment_logs (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      user_name TEXT,
      purpose TEXT NOT NULL,
      title TEXT NOT NULL,
      amount_cents INTEGER NOT NULL,
      gateway TEXT NOT NULL,
      status TEXT NOT NULL,
      reference TEXT,
      item_id TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const adminActivityLogs = '''
    CREATE TABLE admin_activity_logs (
      id TEXT PRIMARY KEY,
      actor_id TEXT,
      actor_name TEXT,
      action TEXT NOT NULL,
      target_type TEXT,
      target_id TEXT,
      details TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static List<String> get all => [
        users,
        wallets,
        courses,
        modules,
        lessons,
        enrollments,
        lessonProgress,
        services,
        jobs,
        games,
        gameSessions,
        aiUsage,
        rooms,
        roomBookings,
        printServices,
        printOrders,
        serviceBookings,
        userReports,
        contactMessages,
        publications,
        paymentLogs,
        adminActivityLogs,
        meta,
      ];
}
