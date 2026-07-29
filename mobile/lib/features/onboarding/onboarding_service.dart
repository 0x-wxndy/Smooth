import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingPrefix = 'smooth_onboarding_seen_';

class OnboardingService {
  Future<bool> hasSeenOnboarding(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_onboardingPrefix$userId') ?? false;
  }

  Future<void> markOnboardingSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_onboardingPrefix$userId', true);
  }
}

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});
