import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class ProviderReview {
  const ProviderReview({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.context,
    required this.dateLabel,
    required this.avatarUrl,
  });

  final String authorName;
  final double rating;
  final String comment;
  final String context;
  final String dateLabel;
  final String avatarUrl;
}

List<ProviderReview> providerReviewsForUser(String userId, S s) {
  return switch (userId) {
    'user_teacher_maria' => [
        ProviderReview(
          authorName: 'Yasmine Khelifi',
          rating: 5,
          comment: s.providerReviewMaria1,
          context: 'Programming Essentials',
          dateLabel: s.feedbackDaysAgo(3),
          avatarUrl: AppAssets.avatar3,
        ),
        ProviderReview(
          authorName: 'Omar Hadj',
          rating: 5,
          comment: s.providerReviewMaria2,
          context: 'Flutter mentoring',
          dateLabel: s.feedbackDaysAgo(7),
          avatarUrl: AppAssets.avatar2,
        ),
        ProviderReview(
          authorName: 'Léa Martins',
          rating: 4.5,
          comment: s.providerReviewMaria3,
          context: 'Marketplace service',
          dateLabel: s.feedbackWeeksAgo(2),
          avatarUrl: AppAssets.avatar4,
        ),
      ],
    'user_teacher_james' => [
        ProviderReview(
          authorName: 'Nadia Saïdi',
          rating: 5,
          comment: s.providerReviewJames1,
          context: 'UI/UX Design',
          dateLabel: s.feedbackDaysAgo(4),
          avatarUrl: AppAssets.avatar3,
        ),
        ProviderReview(
          authorName: 'Karim Boudiaf',
          rating: 4.5,
          comment: s.providerReviewJames2,
          context: 'Brand identity',
          dateLabel: s.feedbackDaysAgo(9),
          avatarUrl: AppAssets.avatar1,
        ),
      ],
    'user_teacher_sarah' => [
        ProviderReview(
          authorName: 'Amine Benali',
          rating: 5,
          comment: s.providerReviewSarah1,
          context: 'Digital Marketing',
          dateLabel: s.feedbackDaysAgo(2),
          avatarUrl: AppAssets.avatar4,
        ),
        ProviderReview(
          authorName: 'Thomas Weber',
          rating: 5,
          comment: s.providerReviewSarah2,
          context: 'SEO workshop',
          dateLabel: s.feedbackWeeksAgo(1),
          avatarUrl: AppAssets.avatar2,
        ),
      ],
    'user_teacher_alex' => [
        ProviderReview(
          authorName: 'Alex Rivera',
          rating: 5,
          comment: s.providerReviewAlex1,
          context: 'Cybersecurity basics',
          dateLabel: s.feedbackDaysAgo(5),
          avatarUrl: AppAssets.avatar2,
        ),
        ProviderReview(
          authorName: 'Sarah Thompson',
          rating: 4.5,
          comment: s.providerReviewAlex2,
          context: 'Pen testing gig',
          dateLabel: s.feedbackWeeksAgo(3),
          avatarUrl: AppAssets.avatar3,
        ),
      ],
    'user_teacher_emma' => [
        ProviderReview(
          authorName: 'Léa Martins',
          rating: 5,
          comment: s.providerReviewEmma1,
          context: 'Business strategy',
          dateLabel: s.feedbackDaysAgo(6),
          avatarUrl: AppAssets.avatar4,
        ),
      ],
    _ => [
        ProviderReview(
          authorName: 'Samooth learner',
          rating: 5,
          comment: s.providerReviewDefault,
          context: s.learn,
          dateLabel: s.feedbackWeeksAgo(1),
          avatarUrl: AppAssets.avatar1,
        ),
      ],
  };
}

class StarRatingRow extends StatelessWidget {
  const StarRatingRow({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: AppColors.accentOrange,
        );
      }),
    );
  }
}

class ProviderReviewCard extends StatelessWidget {
  const ProviderReviewCard({super.key, required this.review, required this.s});

  final ProviderReview review;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.pastelMint,
                  backgroundImage: NetworkImage(review.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      StarRatingRow(rating: review.rating, size: 14),
                    ],
                  ),
                ),
                Text(
                  review.dateLabel,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.45)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s.feedbackOn(review.context),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
