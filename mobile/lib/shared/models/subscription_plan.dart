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
}
