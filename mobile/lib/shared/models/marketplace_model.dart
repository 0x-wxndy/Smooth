class FreelanceService {
  const FreelanceService({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.deliveryDays,
    required this.ratingAvg,
    required this.reviewCount,
    this.providerName,
    this.providerAvatar,
    this.category,
  });

  final String id;
  final String title;
  final String description;
  final int priceCents;
  final int deliveryDays;
  final double ratingAvg;
  final int reviewCount;
  final String? providerName;
  final String? providerAvatar;
  final String? category;

  String get priceLabel => 'From \$${(priceCents / 100).toStringAsFixed(0)}';
}

class JobPosting {
  const JobPosting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.type,
    required this.remote,
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.experienceLevel,
  });

  final String id;
  final String title;
  final String companyName;
  final String type;
  final bool remote;
  final String? location;
  final int? salaryMin;
  final int? salaryMax;
  final String? experienceLevel;

  String get salaryLabel {
    if (salaryMin == null && salaryMax == null) return 'Competitive';
    if (salaryMin != null && salaryMax != null) {
      return '\$${salaryMin! ~/ 1000}k–\$${salaryMax! ~/ 1000}k';
    }
    return 'From \$${(salaryMin ?? salaryMax)! ~/ 1000}k';
  }
}

class GamificationStats {
  const GamificationStats({
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  final int coins;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;

  double get levelProgress => (xp % 300) / 300;
}

class ChatMessage {
  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  final String content;
  final bool isUser;
  final DateTime timestamp;
}

class EducationalGame {
  const EducationalGame({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coinReward,
    required this.xpReward,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int coinReward;
  final int xpReward;
}
