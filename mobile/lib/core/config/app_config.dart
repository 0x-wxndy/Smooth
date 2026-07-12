class AppConfig {
  static const appName = 'Smooth';
  static const aiDailyLimit = 5;
  static const dbName = 'smooth.db';
  static const dbVersion = 3;

  /// Coins / XP earned when completing a lesson.
  static const lessonCoinReward = 15;
  static const lessonXpReward = 20;

  /// Creator economy rewards (teachers / freelancers).
  static const postCourseCoins = 40;
  static const postCourseXp = 60;
  static const postServiceCoins = 30;
  static const postServiceXp = 45;
  static const bookingReceivedCoins = 50;
  static const bookingReceivedXp = 40;
  static const ratingBonusCoins = 25;
  static const ratingBonusXp = 30;

  /// Bonus when a course hits 100% progress.
  static const courseCompleteCoinBonus = 50;
  static const courseCompleteXpBonus = 80;

  /// AI token packs (coins → bonus tokens).
  static const aiPackSmallCoins = 40;
  static const aiPackSmallTokens = 5;
  static const aiPackLargeCoins = 100;
  static const aiPackLargeTokens = 15;

  /// AI packs priced in DZD centimes (for Edahabia / CIB mock checkout).
  static const aiPackSmallDzd = 50000; // 500 د.ج
  static const aiPackLargeDzd = 120000; // 1 200 د.ج

  /// Pre-seeded demo accounts (works offline, no backend).
  static const demoPassword = 'demo1234';
  static const demoLearnerEmail = 'demo@smooth.app';
  static const demoTeacherEmail = 'maria@smooth.app';
  static const demoClientEmail = 'client@smooth.app';
  static const demoEmail = demoLearnerEmail;
}
