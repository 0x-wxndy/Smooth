import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/config/app_config.dart';

abstract final class DatabaseSeeder {
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode('smooth:$password')).toString();
  }

  static Future<void> seedIfNeeded(Database db) async {
    final row = await db.query('app_meta', where: 'key = ?', whereArgs: ['seeded']);
    if (row.isNotEmpty && row.first['value'] == '1') return;

    await db.transaction((txn) async {
      await _seedUsers(txn);
      await _seedCourses(txn);
      await _seedServices(txn);
      await _seedJobs(txn);
      await _seedGames(txn);
      await txn.insert('app_meta', {'key': 'seeded', 'value': '1'});
    });
  }

  static Future<void> _seedUsers(Transaction txn) async {
    const now = '2026-01-01T00:00:00Z';
    final users = [
      {
        'id': 'user_demo',
        'email': AppConfig.demoEmail,
        'password_hash': hashPassword(AppConfig.demoPassword),
        'display_name': 'Alex Learner',
        'role': 'LEARNER',
        'avatar_url': null,
        'bio': 'Passionate about mobile development and design.',
        'created_at': now,
      },
      {
        'id': 'user_teacher_maria',
        'email': 'maria@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'Maria Chen',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Full-stack developer & Flutter instructor. 2,400+ students.',
        'created_at': now,
      },
      {
        'id': 'user_teacher_james',
        'email': 'james@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'James Okonkwo',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'UI/UX designer with 10 years of product experience.',
        'created_at': now,
      },
      {
        'id': 'user_teacher_sarah',
        'email': 'sarah@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'Sarah Kim',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'React Native expert and mobile architect.',
        'created_at': now,
      },
      {
        'id': 'user_teacher_alex',
        'email': 'alex@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'Alex Rivera',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Cybersecurity consultant and ethical hacker.',
        'created_at': now,
      },
      {
        'id': 'user_teacher_emma',
        'email': 'emma@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'Emma Laurent',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Digital marketing strategist for global brands.',
        'created_at': now,
      },
      {
        'id': 'user_client',
        'email': 'client@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'TechCorp HR',
        'role': 'CLIENT',
        'avatar_url': null,
        'bio': 'Hiring top talent for innovative projects.',
        'created_at': now,
      },
      {
        'id': 'user_provider_design',
        'email': 'studio@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'Design Studio Pro',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Award-winning branding and logo design studio.',
        'created_at': now,
      },
      {
        'id': 'user_provider_dev',
        'email': 'devcraft@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'DevCraft Agency',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Full-stack development agency.',
        'created_at': now,
      },
      {
        'id': 'user_provider_ui',
        'email': 'pixelflow@smooth.app',
        'password_hash': hashPassword('demo1234'),
        'display_name': 'PixelFlow',
        'role': 'TEACHER',
        'avatar_url': null,
        'bio': 'Mobile-first UI/UX design collective.',
        'created_at': now,
      },
    ];

    for (final u in users) {
      await txn.insert('users', u);
    }

    await txn.insert('gamification_wallets', {
      'user_id': 'user_demo',
      'coins': 420,
      'xp': 1240,
      'level': 5,
      'current_streak': 7,
      'longest_streak': 14,
      'last_login_date': null,
    });

    for (final id in [
      'user_teacher_maria',
      'user_teacher_james',
      'user_teacher_sarah',
      'user_teacher_alex',
      'user_teacher_emma',
      'user_client',
      'user_provider_design',
      'user_provider_dev',
      'user_provider_ui',
    ]) {
      await txn.insert('gamification_wallets', {
        'user_id': id,
        'coins': 100,
        'xp': 500,
        'level': 3,
        'current_streak': 0,
        'longest_streak': 0,
      });
    }

    await txn.insert('enrollments', {
      'user_id': 'user_demo',
      'course_id': 'course_1',
      'progress_percent': 45,
      'bookmarked': 1,
    });

    for (final lessonId in ['lesson_1', 'lesson_2']) {
      await txn.insert('lesson_progress', {
        'user_id': 'user_demo',
        'lesson_id': lessonId,
        'completed': 1,
      });
    }
  }

  static Future<void> _seedCourses(Transaction txn) async {
    final courses = [
      {
        'id': 'course_1',
        'teacher_id': 'user_teacher_maria',
        'title': 'Flutter for Beginners',
        'description':
            'Build beautiful cross-platform apps from scratch with Flutter and Dart.',
        'category': 'softwareDev',
        'difficulty': 'beginner',
        'duration_minutes': 480,
        'skills': 'Dart,Flutter,Widgets,State',
        'is_free': 1,
        'price_cents': null,
        'rating_avg': 4.9,
        'enrollment_count': 2840,
      },
      {
        'id': 'course_2',
        'teacher_id': 'user_teacher_james',
        'title': 'UI/UX Design Fundamentals',
        'description': 'Master visual hierarchy, typography, and prototyping in Figma.',
        'category': 'uiUx',
        'difficulty': 'beginner',
        'duration_minutes': 360,
        'skills': 'Figma,Typography,Layout',
        'is_free': 1,
        'price_cents': null,
        'rating_avg': 4.8,
        'enrollment_count': 1920,
      },
      {
        'id': 'course_3',
        'teacher_id': 'user_teacher_sarah',
        'title': 'React Native Pro',
        'description': 'Advanced patterns for production mobile applications.',
        'category': 'softwareDev',
        'difficulty': 'advanced',
        'duration_minutes': 720,
        'skills': 'React Native,TypeScript,Performance',
        'is_free': 0,
        'price_cents': 4999,
        'rating_avg': 4.9,
        'enrollment_count': 890,
      },
      {
        'id': 'course_4',
        'teacher_id': 'user_teacher_alex',
        'title': 'Cybersecurity Essentials',
        'description':
            'Learn threat modeling, network security, and ethical hacking basics.',
        'category': 'cybersecurity',
        'difficulty': 'intermediate',
        'duration_minutes': 540,
        'skills': 'Networking,Pentesting,OWASP',
        'is_free': 1,
        'price_cents': null,
        'rating_avg': 4.7,
        'enrollment_count': 1560,
      },
      {
        'id': 'course_5',
        'teacher_id': 'user_teacher_emma',
        'title': 'Digital Marketing Strategy',
        'description': 'SEO, social media, and growth marketing for modern brands.',
        'category': 'digitalMarketing',
        'difficulty': 'intermediate',
        'duration_minutes': 300,
        'skills': 'SEO,Analytics,Content',
        'is_free': 0,
        'price_cents': 2999,
        'rating_avg': 4.6,
        'enrollment_count': 720,
      },
      {
        'id': 'course_6',
        'teacher_id': 'user_teacher_maria',
        'title': 'Dart Programming Mastery',
        'description': 'Deep dive into Dart language features and async programming.',
        'category': 'softwareDev',
        'difficulty': 'intermediate',
        'duration_minutes': 420,
        'skills': 'Dart,Async,Generics',
        'is_free': 1,
        'price_cents': null,
        'rating_avg': 4.85,
        'enrollment_count': 1100,
      },
      {
        'id': 'course_7',
        'teacher_id': 'user_teacher_james',
        'title': 'Figma Prototyping',
        'description': 'Create interactive prototypes and design systems in Figma.',
        'category': 'uiUx',
        'difficulty': 'intermediate',
        'duration_minutes': 240,
        'skills': 'Figma,Prototyping,Design Systems',
        'is_free': 0,
        'price_cents': 1999,
        'rating_avg': 4.75,
        'enrollment_count': 640,
      },
      {
        'id': 'course_8',
        'teacher_id': 'user_teacher_alex',
        'title': 'Ethical Hacking Lab',
        'description': 'Hands-on penetration testing in controlled lab environments.',
        'category': 'cybersecurity',
        'difficulty': 'advanced',
        'duration_minutes': 600,
        'skills': 'Kali Linux,Metasploit,Reporting',
        'is_free': 0,
        'price_cents': 5999,
        'rating_avg': 4.92,
        'enrollment_count': 430,
      },
    ];

    for (final c in courses) {
      await txn.insert('courses', c);
    }

    // Course 1 modules (full curriculum)
    await txn.insert('course_modules', {
      'id': 'module_1_1',
      'course_id': 'course_1',
      'title': 'Getting Started',
      'sort_order': 1,
    });
    await txn.insert('course_modules', {
      'id': 'module_1_2',
      'course_id': 'course_1',
      'title': 'State Management',
      'sort_order': 2,
    });

    final lessons1 = [
      {'id': 'lesson_1', 'module_id': 'module_1_1', 'title': 'Intro to Flutter', 'duration_minutes': 12, 'sort_order': 1},
      {'id': 'lesson_2', 'module_id': 'module_1_1', 'title': 'Setting up your environment', 'duration_minutes': 18, 'sort_order': 2},
      {'id': 'lesson_3', 'module_id': 'module_1_1', 'title': 'Your first widget tree', 'duration_minutes': 22, 'sort_order': 3},
      {'id': 'lesson_4', 'module_id': 'module_1_2', 'title': 'setState basics', 'duration_minutes': 15, 'sort_order': 1},
      {'id': 'lesson_5', 'module_id': 'module_1_2', 'title': 'Riverpod introduction', 'duration_minutes': 28, 'sort_order': 2},
    ];
    for (final l in lessons1) {
      await txn.insert('lessons', l);
    }

    // Generic module for other courses
    for (final courseId in ['course_2', 'course_3', 'course_4', 'course_5', 'course_6', 'course_7', 'course_8']) {
      final modId = 'module_${courseId}_1';
      await txn.insert('course_modules', {
        'id': modId,
        'course_id': courseId,
        'title': 'Introduction',
        'sort_order': 1,
      });
      await txn.insert('lessons', {
        'id': 'lesson_${courseId}_1',
        'module_id': modId,
        'title': 'Course overview',
        'duration_minutes': 10,
        'sort_order': 1,
      });
      await txn.insert('lessons', {
        'id': 'lesson_${courseId}_2',
        'module_id': modId,
        'title': 'Core concepts',
        'duration_minutes': 20,
        'sort_order': 2,
      });
    }
  }

  static Future<void> _seedServices(Transaction txn) async {
    final services = [
      {
        'id': 'service_1',
        'provider_id': 'user_provider_design',
        'title': 'Professional Logo Design',
        'description': 'Custom logo with 3 revisions and brand guidelines.',
        'category': 'Graphic Design',
        'price_cents': 15000,
        'delivery_days': 3,
        'rating_avg': 4.95,
        'review_count': 128,
      },
      {
        'id': 'service_2',
        'provider_id': 'user_provider_dev',
        'title': 'Full-Stack Web Development',
        'description': 'Responsive web apps with React and Node.js backend.',
        'category': 'Web Development',
        'price_cents': 250000,
        'delivery_days': 21,
        'rating_avg': 4.88,
        'review_count': 64,
      },
      {
        'id': 'service_3',
        'provider_id': 'user_provider_ui',
        'title': 'Mobile App UI/UX',
        'description': 'Complete mobile app design with interactive prototype.',
        'category': 'UI/UX',
        'price_cents': 80000,
        'delivery_days': 10,
        'rating_avg': 4.92,
        'review_count': 89,
      },
      {
        'id': 'service_4',
        'provider_id': 'user_teacher_maria',
        'title': 'Flutter App Development',
        'description': 'Cross-platform mobile app built with Flutter, delivered in 4 weeks.',
        'category': 'Mobile Development',
        'price_cents': 350000,
        'delivery_days': 28,
        'rating_avg': 4.97,
        'review_count': 45,
      },
      {
        'id': 'service_5',
        'provider_id': 'user_teacher_alex',
        'title': 'Security Audit',
        'description': 'Comprehensive security assessment for web and mobile applications.',
        'category': 'Cybersecurity',
        'price_cents': 120000,
        'delivery_days': 7,
        'rating_avg': 4.91,
        'review_count': 32,
      },
    ];
    for (final s in services) {
      await txn.insert('services', s);
    }
  }

  static Future<void> _seedJobs(Transaction txn) async {
    final jobs = [
      {
        'id': 'job_1',
        'company_name': 'TechCorp',
        'title': 'Senior Flutter Developer',
        'type': 'Full-time',
        'remote': 1,
        'location': null,
        'salary_min': 90000,
        'salary_max': 120000,
        'experience_level': 'Senior',
        'description': 'Build and maintain cross-platform apps for millions of users.',
      },
      {
        'id': 'job_2',
        'company_name': 'Studio X',
        'title': 'UX Design Intern',
        'type': 'Internship',
        'remote': 0,
        'location': 'Paris, France',
        'salary_min': null,
        'salary_max': null,
        'experience_level': 'Entry',
        'description': 'Join our design team to create delightful product experiences.',
      },
      {
        'id': 'job_3',
        'company_name': 'SecureNet',
        'title': 'Cybersecurity Consultant',
        'type': 'Freelance',
        'remote': 1,
        'location': null,
        'salary_min': 80000,
        'salary_max': 100000,
        'experience_level': 'Mid',
        'description': 'Conduct penetration tests and security audits for enterprise clients.',
      },
      {
        'id': 'job_4',
        'company_name': 'GrowthLabs',
        'title': 'Digital Marketing Manager',
        'type': 'Full-time',
        'remote': 1,
        'location': null,
        'salary_min': 65000,
        'salary_max': 85000,
        'experience_level': 'Mid',
        'description': 'Lead SEO, content, and paid campaigns for SaaS products.',
      },
      {
        'id': 'job_5',
        'company_name': 'AI Ventures',
        'title': 'Machine Learning Engineer',
        'type': 'Full-time',
        'remote': 0,
        'location': 'San Francisco, CA',
        'salary_min': 130000,
        'salary_max': 170000,
        'experience_level': 'Senior',
        'description': 'Design and deploy ML models for ed-tech products.',
      },
    ];
    for (final j in jobs) {
      await txn.insert('job_postings', j);
    }
  }

  static Future<void> _seedGames(Transaction txn) async {
    final games = [
      {
        'id': 'game_1',
        'title': 'Code Quiz Sprint',
        'description': 'Answer programming questions against the clock.',
        'category': 'Programming',
        'coin_reward': 10,
        'xp_reward': 25,
      },
      {
        'id': 'game_2',
        'title': 'Logic Puzzle Lab',
        'description': 'Solve algorithmic puzzles to sharpen problem-solving.',
        'category': 'Logic',
        'coin_reward': 8,
        'xp_reward': 20,
      },
      {
        'id': 'game_3',
        'title': 'Security Challenge',
        'description': 'Identify vulnerabilities in simulated scenarios.',
        'category': 'Cybersecurity',
        'coin_reward': 15,
        'xp_reward': 30,
      },
      {
        'id': 'game_4',
        'title': 'Vocabulary Builder',
        'description': 'Expand your tech vocabulary with flashcard games.',
        'category': 'Languages',
        'coin_reward': 6,
        'xp_reward': 15,
      },
      {
        'id': 'game_5',
        'title': 'Memory Match: Design Patterns',
        'description': 'Match design patterns to their descriptions.',
        'category': 'Programming',
        'coin_reward': 12,
        'xp_reward': 22,
      },
    ];
    for (final g in games) {
      await txn.insert('educational_games', g);
    }
  }
}
