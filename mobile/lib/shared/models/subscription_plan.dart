import '../../core/config/app_config.dart';

enum SubscriptionPlan {
  free,
  premium,
  vip,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String storageKey() => name;

  static SubscriptionPlan fromKey(String? key) {
    return SubscriptionPlan.values.firstWhere(
      (p) => p.name == key,
      orElse: () => SubscriptionPlan.free,
    );
  }

  /// Monthly price in DZD centimes (0 for free).
  int get priceCentimes => switch (this) {
        SubscriptionPlan.free => 0,
        SubscriptionPlan.premium => 199000, // 1 990 DZD / month
        SubscriptionPlan.vip => 1490000, // 14 900 DZD / year
      };

  bool get isPaid => this != SubscriptionPlan.free;

  /// Free tier: max enrolled masterclasses; paid tiers: unlimited.
  int? get masterclassLimit => switch (this) {
        SubscriptionPlan.free => 3,
        _ => null,
      };

  /// Daily AI messages included with the plan.
  int get aiDailyLimit => switch (this) {
        SubscriptionPlan.free => AppConfig.aiDailyLimit,
        SubscriptionPlan.premium => 20,
        SubscriptionPlan.vip => 999,
      };

  /// Paid tiers include premium (paid) courses without per-course checkout.
  bool get includesPaidCourses => isPaid;

  bool get hasSourceFiles => isPaid;
  bool get hasPriorityReview => isPaid;
  bool get hasWebinars => isPaid;
  bool get hasMentoring => this == SubscriptionPlan.vip;
}
