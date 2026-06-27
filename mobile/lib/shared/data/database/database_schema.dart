abstract final class DatabaseSchema {
  static const users = '''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      display_name TEXT NOT NULL,
      role TEXT NOT NULL,
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
        aiUsage,
        meta,
      ];
}
