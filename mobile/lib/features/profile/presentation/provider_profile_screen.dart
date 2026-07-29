import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/smooth_button.dart';
import 'provider_actions.dart';
import 'provider_feedback.dart';
import 'provider_reviews_service.dart';

final providerProfileProvider = FutureProvider.family<AppUser?, String>((ref, userId) async {
  return ref.watch(databaseProvider).findUserById(userId);
});

final providerServicesProvider = FutureProvider.family<List<FreelanceService>, String>((ref, userId) async {
  return ref.watch(databaseProvider).getServicesByProvider(userId);
});

final providerCoursesProvider = FutureProvider.family<List<Course>, String>((ref, userId) async {
  return ref.watch(databaseProvider).getCoursesByTeacher(userId);
});

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final userAsync = ref.watch(providerProfileProvider(userId));
    final servicesAsync = ref.watch(providerServicesProvider(userId));
    final coursesAsync = ref.watch(providerCoursesProvider(userId));
    final statsAsync = ref.watch(providerStatsProvider(userId));
    final reviewsAsync = ref.watch(providerReviewsListProvider(userId));
    final me = ref.watch(authProvider).user;

    return Scaffold(
      body: AsyncValueContent(
        value: userAsync,
        builder: (user) {
          if (user == null) {
            return Center(child: Text(s.userNotFound));
          }
          final canInteract = me != null && me.id != user.id && user.role != UserRole.admin;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(user.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    child: Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white24,
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.displayName.characters.first.toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          roleDisplayName(user.role),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(user.bio!, style: const TextStyle(height: 1.45, color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: 18),
                      AsyncValueContent(
                        value: statsAsync,
                        builder: (stats) => _ProviderRatingSummary(
                          rating: stats.ratingAvg,
                          reviewCount: stats.reviewCount,
                          s: s,
                        ),
                      ),
                      if (canInteract) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => showContactProviderSheet(context: context, ref: ref, provider: user),
                                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                                label: Text(s.contactProvider),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => showLeaveReviewSheet(
                                  context: context,
                                  ref: ref,
                                  providerId: userId,
                                  providerName: user.displayName,
                                ),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.accentPurple),
                                icon: const Icon(Icons.rate_review_outlined, size: 18),
                                label: Text(s.leaveReview),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      Text(s.availableCourses, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      AsyncValueContent(
                        value: coursesAsync,
                        builder: (courses) {
                          if (courses.isEmpty) {
                            return Text(s.noCoursesYet, style: const TextStyle(color: AppColors.textSecondary));
                          }
                          return Column(
                            children: courses
                                .map(
                                  (course) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: CourseCard(
                                      course: course,
                                      onTap: () => context.push('/courses/${course.id}'),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(s.services, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      AsyncValueContent(
                        value: servicesAsync,
                        builder: (services) {
                          if (services.isEmpty) {
                            return Text(s.noServicesYet, style: const TextStyle(color: AppColors.textSecondary));
                          }
                          return Column(
                            children: services
                                .map(
                                  (svc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ServiceCard(
                                      service: svc,
                                      onTap: () => context.push('/services/${svc.id}'),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(s.feedbackRecent, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 10),
                      AsyncValueContent(
                        value: reviewsAsync,
                        builder: (reviews) {
                          if (reviews.isEmpty) {
                            return Text(s.noReviewsYet, style: const TextStyle(color: AppColors.textSecondary));
                          }
                          return Column(
                            children: reviews.map((r) => ProviderReviewCard(review: r, s: s)).toList(),
                          );
                        },
                      ),
                      if (canInteract) ...[
                        const SizedBox(height: 12),
                        SmoothButton(
                          label: s.reportUser,
                          variant: SmoothButtonVariant.outline,
                          icon: Icons.flag_outlined,
                          onPressed: () => context.push('/report/${user.id}', extra: user.displayName),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderRatingSummary extends StatelessWidget {
  const _ProviderRatingSummary({
    required this.rating,
    required this.reviewCount,
    required this.s,
  });

  final double rating;
  final int reviewCount;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
              StarRatingRow(rating: rating, size: 18),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.averageRating, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  s.reviewsCount(reviewCount),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String featuredAvatarForIndex(int index) {
  return [AppAssets.avatar2, AppAssets.avatar3, AppAssets.avatar4][index % 3];
}
