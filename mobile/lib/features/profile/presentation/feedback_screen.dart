import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';

class FeedbackExample {
  const FeedbackExample({
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

List<FeedbackExample> feedbackExamplesForRole(UserRole? role, S s) {
  switch (role) {
    case UserRole.teacher:
      return [
        FeedbackExample(
          authorName: 'Yasmine Khelifi',
          rating: 5,
          comment: s.feedbackExTeacher1,
          context: 'Programming Essentials',
          dateLabel: s.feedbackDaysAgo(3),
          avatarUrl: AppAssets.avatar3,
        ),
        FeedbackExample(
          authorName: 'Omar Hadj',
          rating: 5,
          comment: s.feedbackExTeacher2,
          context: 'Studio A · Hub',
          dateLabel: s.feedbackDaysAgo(6),
          avatarUrl: AppAssets.avatar2,
        ),
        FeedbackExample(
          authorName: 'Léa Martins',
          rating: 4.5,
          comment: s.feedbackExTeacher3,
          context: 'Logo Design',
          dateLabel: s.feedbackWeeksAgo(2),
          avatarUrl: AppAssets.avatar4,
        ),
        FeedbackExample(
          authorName: 'Karim Boudiaf',
          rating: 5,
          comment: s.feedbackExTeacher4,
          context: 'Marketplace',
          dateLabel: s.feedbackWeeksAgo(3),
          avatarUrl: AppAssets.avatar1,
        ),
      ];
    case UserRole.client:
      return [
        FeedbackExample(
          authorName: 'Alex Rivera',
          rating: 5,
          comment: s.feedbackExClient1,
          context: 'Mobile App MVP',
          dateLabel: s.feedbackDaysAgo(2),
          avatarUrl: AppAssets.avatar2,
        ),
        FeedbackExample(
          authorName: 'Nadia Saïdi',
          rating: 4.5,
          comment: s.feedbackExClient2,
          context: 'Brand refresh',
          dateLabel: s.feedbackDaysAgo(8),
          avatarUrl: AppAssets.avatar3,
        ),
        FeedbackExample(
          authorName: 'Thomas Weber',
          rating: 5,
          comment: s.feedbackExClient3,
          context: 'SEO campaign',
          dateLabel: s.feedbackWeeksAgo(1),
          avatarUrl: AppAssets.avatar4,
        ),
      ];
    case UserRole.admin:
      return [
        FeedbackExample(
          authorName: 'Maria Chen',
          rating: 5,
          comment: s.feedbackExAdmin1,
          context: 'Hub facilities',
          dateLabel: s.feedbackDaysAgo(4),
          avatarUrl: AppAssets.avatar3,
        ),
        FeedbackExample(
          authorName: 'Karim Boudiaf',
          rating: 4.5,
          comment: s.feedbackExAdmin2,
          context: 'Print service',
          dateLabel: s.feedbackDaysAgo(9),
          avatarUrl: AppAssets.avatar1,
        ),
        FeedbackExample(
          authorName: 'Yasmine Khelifi',
          rating: 5,
          comment: s.feedbackExAdmin3,
          context: 'Room booking',
          dateLabel: s.feedbackWeeksAgo(2),
          avatarUrl: AppAssets.avatar4,
        ),
      ];
    case UserRole.learner:
    default:
      return [
        FeedbackExample(
          authorName: 'Recruiter · TechDZ',
          rating: 5,
          comment: s.feedbackExLearner1,
          context: s.feedbackPortfolioCase,
          dateLabel: s.feedbackDaysAgo(1),
          avatarUrl: AppAssets.avatar2,
        ),
        FeedbackExample(
          authorName: 'Amine Benali',
          rating: 5,
          comment: s.feedbackExLearner2,
          context: 'React Native project',
          dateLabel: s.feedbackDaysAgo(5),
          avatarUrl: AppAssets.avatar4,
        ),
        FeedbackExample(
          authorName: 'Sarah Thompson',
          rating: 4.5,
          comment: s.feedbackExLearner3,
          context: 'UI portfolio',
          dateLabel: s.feedbackWeeksAgo(1),
          avatarUrl: AppAssets.avatar3,
        ),
        FeedbackExample(
          authorName: 'Omar Hadj',
          rating: 5,
          comment: s.feedbackExLearner4,
          context: 'Peer review',
          dateLabel: s.feedbackWeeksAgo(2),
          avatarUrl: AppAssets.avatar2,
        ),
      ];
  }
}

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final user = ref.watch(authProvider).user;
    final examples = feedbackExamplesForRole(user?.role, s);
    final average = examples.map((e) => e.rating).reduce((a, b) => a + b) / examples.length;

    return Scaffold(
      appBar: AppBar(title: Text(s.feedbackTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _FeedbackSummaryCard(
            average: average,
            count: examples.length,
            s: s,
          ),
          const SizedBox(height: 16),
          Text(s.feedbackRecent, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          ...examples.map((e) => _FeedbackCard(example: e, s: s)),
        ],
      ),
    );
  }
}

class _FeedbackSummaryCard extends StatelessWidget {
  const _FeedbackSummaryCard({
    required this.average,
    required this.count,
    required this.s,
  });

  final double average;
  final int count;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.accentPurple.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
              _StarRow(rating: average, size: 18),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.averageRating, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  s.reviewsCount(count),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  s.feedbackSubtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.example, required this.s});

  final FeedbackExample example;
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
                  backgroundImage: NetworkImage(example.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(example.authorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      _StarRow(rating: example.rating, size: 14),
                    ],
                  ),
                ),
                Text(
                  example.dateLabel,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              example.comment,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s.feedbackOn(example.context),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 16});

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
