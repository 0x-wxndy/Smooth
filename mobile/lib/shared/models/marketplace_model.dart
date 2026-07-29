import '../../core/utils/money.dart';

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
    this.providerId,
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
  final String? providerId;
  final String? category;

  String get priceLabel => Money.format(priceCents);

  String priceFromLabel(String fromPrefix) => '$fromPrefix ${Money.format(priceCents)}';
}

/// Top-rated freelancer / teacher shown on the marketplace.
class FeaturedProvider {
  const FeaturedProvider({
    required this.userId,
    required this.displayName,
    required this.headline,
    required this.ratingAvg,
    required this.priceCents,
    required this.tags,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final String headline;
  final double ratingAvg;
  final int priceCents;
  final List<String> tags;
  final String? avatarUrl;

  String hourlyLabel(String perHourSuffix) => Money.perHour(priceCents ~/ 30, perHourSuffix: perHourSuffix);
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

  /// salaryMin/Max stored as whole DZD.
  String get salaryLabel {
    if (salaryMin == null && salaryMax == null) return '—';
    if (salaryMin != null && salaryMax != null) {
      return '${Money.format(salaryMin! * 100)} – ${Money.format(salaryMax! * 100)}';
    }
    return Money.format((salaryMin ?? salaryMax)! * 100);
  }
}

class GamificationStats {
  const GamificationStats({
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.aiTokenBank = 0,
  });

  final int coins;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int aiTokenBank;

  double get levelProgress => (xp % 300) / 300;
}

class AiQuota {
  const AiQuota({
    required this.freeUsed,
    required this.freeLimit,
    required this.bank,
  });

  final int freeUsed;
  final int freeLimit;
  final int bank;

  int get freeRemaining => (freeLimit - freeUsed).clamp(0, freeLimit);
  int get totalRemaining => freeRemaining + bank;
  bool get canSend => totalRemaining > 0;
}

class RewardResult {
  const RewardResult({
    this.coins = 0,
    this.xp = 0,
    this.alreadyDone = false,
    this.message,
  });

  final int coins;
  final int xp;
  final bool alreadyDone;
  final String? message;
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
