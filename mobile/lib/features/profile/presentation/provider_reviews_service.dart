import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import 'provider_feedback.dart';

const _reviewsPrefix = 'smooth_provider_reviews_';

class ProviderReviewsService {
  Future<List<ProviderReview>> getReviews(String providerId, S s, {List<ProviderReview> seed = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_reviewsPrefix$providerId') ?? [];
    final stored = raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return ProviderReview(
        authorName: map['authorName'] as String,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String,
        context: map['context'] as String? ?? '',
        dateLabel: s.feedbackDaysAgo(0),
        avatarUrl: (map['avatarUrl'] as String?)?.isNotEmpty == true
            ? map['avatarUrl'] as String
            : AppAssets.avatar1,
      );
    }).toList();
    return [...stored, ...seed];
  }

  Future<void> addReview({
    required String providerId,
    required String authorName,
    required double rating,
    required String comment,
    required String context,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_reviewsPrefix$providerId';
    final existing = prefs.getStringList(key) ?? [];
    final entry = jsonEncode({
      'authorName': authorName,
      'rating': rating,
      'comment': comment,
      'context': context,
      'dateLabel': 'now',
      'avatarUrl': avatarUrl ?? '',
    });
    await prefs.setStringList(key, [entry, ...existing]);
  }
}

final providerReviewsServiceProvider = Provider<ProviderReviewsService>((ref) {
  return ProviderReviewsService();
});

final providerReviewsListProvider =
    FutureProvider.family<List<ProviderReview>, String>((ref, providerId) async {
  final locale = ref.watch(localeProvider);
  final s = S(locale);
  final seed = providerReviewsForUser(providerId, s);
  return ref.watch(providerReviewsServiceProvider).getReviews(providerId, s, seed: seed);
});
