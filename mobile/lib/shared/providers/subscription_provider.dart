import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
export '../models/subscription_plan.dart';
import '../models/subscription_plan.dart';
import 'app_providers.dart';

const _planPrefix = 'smooth_subscription_plan_';

class SubscriptionNotifier extends StateNotifier<SubscriptionPlan> {
  SubscriptionNotifier(this._ref) : super(SubscriptionPlan.free) {
    _load();
    _ref.listen<AuthState>(authProvider, (prev, next) {
      final id = next.user?.id;
      if (id != null) {
        _loadForUser(id);
      } else {
        state = SubscriptionPlan.free;
      }
    });
  }

  final Ref _ref;

  Future<void> _load() async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;
    await _loadForUser(userId);
  }

  Future<void> _loadForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    state = SubscriptionPlanX.fromKey(prefs.getString('$_planPrefix$userId'));
  }

  Future<void> selectPlan(SubscriptionPlan plan) async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;
    state = plan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_planPrefix$userId', plan.storageKey());
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionPlan>((ref) {
  return SubscriptionNotifier(ref);
});
