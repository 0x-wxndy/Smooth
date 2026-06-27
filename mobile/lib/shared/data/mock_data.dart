import '../../shared/models/course_model.dart';
import '../../shared/models/marketplace_model.dart';

abstract final class MockData {
  static const gamification = GamificationStats(
    coins: 420,
    xp: 1240,
    level: 5,
    currentStreak: 7,
    longestStreak: 14,
  );

  static final courses = [
    const Course(
      id: '1',
      title: 'Flutter for Beginners',
      description:
          'Build beautiful cross-platform apps from scratch with Flutter and Dart.',
      category: CourseCategory.softwareDev,
      difficulty: Difficulty.beginner,
      durationMinutes: 480,
      skills: ['Dart', 'Flutter', 'Widgets', 'State'],
      isFree: true,
      ratingAvg: 4.9,
      enrollmentCount: 2840,
      progressPercent: 45,
      teacherName: 'Maria Chen',
    ),
    const Course(
      id: '2',
      title: 'UI/UX Design Fundamentals',
      description: 'Master visual hierarchy, typography, and prototyping in Figma.',
      category: CourseCategory.uiUx,
      difficulty: Difficulty.beginner,
      durationMinutes: 360,
      skills: ['Figma', 'Typography', 'Layout'],
      isFree: true,
      ratingAvg: 4.8,
      enrollmentCount: 1920,
      teacherName: 'James Okonkwo',
    ),
    const Course(
      id: '3',
      title: 'React Native Pro',
      description: 'Advanced patterns for production mobile applications.',
      category: CourseCategory.softwareDev,
      difficulty: Difficulty.advanced,
      durationMinutes: 720,
      skills: ['React Native', 'TypeScript', 'Performance'],
      isFree: false,
      priceCents: 4999,
      ratingAvg: 4.9,
      enrollmentCount: 890,
      teacherName: 'Sarah Kim',
    ),
    const Course(
      id: '4',
      title: 'Cybersecurity Essentials',
      description: 'Learn threat modeling, network security, and ethical hacking basics.',
      category: CourseCategory.cybersecurity,
      difficulty: Difficulty.intermediate,
      durationMinutes: 540,
      skills: ['Networking', 'Pentesting', 'OWASP'],
      isFree: true,
      ratingAvg: 4.7,
      enrollmentCount: 1560,
      teacherName: 'Alex Rivera',
    ),
    const Course(
      id: '5',
      title: 'Digital Marketing Strategy',
      description: 'SEO, social media, and growth marketing for modern brands.',
      category: CourseCategory.digitalMarketing,
      difficulty: Difficulty.intermediate,
      durationMinutes: 300,
      skills: ['SEO', 'Analytics', 'Content'],
      isFree: false,
      priceCents: 2999,
      ratingAvg: 4.6,
      enrollmentCount: 720,
      teacherName: 'Emma Laurent',
    ),
  ];

  static final courseModules = [
    const CourseModule(
      id: 'm1',
      title: 'Getting Started',
      lessons: [
        Lesson(id: 'l1', title: 'Intro to Flutter', durationMinutes: 12, completed: true),
        Lesson(id: 'l2', title: 'Setting up your environment', durationMinutes: 18, completed: true),
        Lesson(id: 'l3', title: 'Your first widget tree', durationMinutes: 22),
      ],
    ),
    const CourseModule(
      id: 'm2',
      title: 'State Management',
      lessons: [
        Lesson(id: 'l4', title: 'setState basics', durationMinutes: 15),
        Lesson(id: 'l5', title: 'Riverpod introduction', durationMinutes: 28),
      ],
    ),
  ];

  static final services = [
    const FreelanceService(
      id: 's1',
      title: 'Professional Logo Design',
      description: 'Custom logo with 3 revisions and brand guidelines.',
      priceCents: 15000,
      deliveryDays: 3,
      ratingAvg: 4.95,
      reviewCount: 128,
      providerName: 'Design Studio Pro',
      category: 'Graphic Design',
    ),
    const FreelanceService(
      id: 's2',
      title: 'Full-Stack Web Development',
      description: 'Responsive web apps with React and Node.js backend.',
      priceCents: 250000,
      deliveryDays: 21,
      ratingAvg: 4.88,
      reviewCount: 64,
      providerName: 'DevCraft Agency',
      category: 'Web Development',
    ),
    const FreelanceService(
      id: 's3',
      title: 'Mobile App UI/UX',
      description: 'Complete mobile app design with interactive prototype.',
      priceCents: 80000,
      deliveryDays: 10,
      ratingAvg: 4.92,
      reviewCount: 89,
      providerName: 'PixelFlow',
      category: 'UI/UX',
    ),
  ];

  static final jobs = [
    const JobPosting(
      id: 'j1',
      title: 'Senior Flutter Developer',
      companyName: 'TechCorp',
      type: 'Full-time',
      remote: true,
      salaryMin: 90000,
      salaryMax: 120000,
      experienceLevel: 'Senior',
    ),
    const JobPosting(
      id: 'j2',
      title: 'UX Design Intern',
      companyName: 'Studio X',
      type: 'Internship',
      remote: false,
      location: 'Paris, France',
      experienceLevel: 'Entry',
    ),
    const JobPosting(
      id: 'j3',
      title: 'Cybersecurity Consultant',
      companyName: 'SecureNet',
      type: 'Freelance',
      remote: true,
      salaryMin: 80000,
      salaryMax: 100000,
      experienceLevel: 'Mid',
    ),
  ];

  static final games = [
    const EducationalGame(
      id: 'g1',
      title: 'Code Quiz Sprint',
      description: 'Answer programming questions against the clock.',
      category: 'Programming',
      coinReward: 10,
      xpReward: 25,
    ),
    const EducationalGame(
      id: 'g2',
      title: 'Logic Puzzle Lab',
      description: 'Solve algorithmic puzzles to sharpen problem-solving.',
      category: 'Logic',
      coinReward: 8,
      xpReward: 20,
    ),
    const EducationalGame(
      id: 'g3',
      title: 'Security Challenge',
      description: 'Identify vulnerabilities in simulated scenarios.',
      category: 'Cybersecurity',
      coinReward: 15,
      xpReward: 30,
    ),
  ];

  static const categories = [
    ('Dev', CourseCategory.softwareDev),
    ('Design', CourseCategory.uiUx),
    ('Marketing', CourseCategory.digitalMarketing),
    ('Security', CourseCategory.cybersecurity),
    ('AI', CourseCategory.ai),
    ('Business', CourseCategory.business),
  ];
}
