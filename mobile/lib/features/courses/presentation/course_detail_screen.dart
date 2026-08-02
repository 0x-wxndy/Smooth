import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/payments/payment_models.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/provider_name_link.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../profile/presentation/provider_actions.dart';
import '../../profile/presentation/provider_profile_screen.dart';
import '../../profile/presentation/provider_review_form.dart';
import '../../../shared/widgets/smooth_components.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));
    final walletAsync = ref.watch(gamificationProvider);
    final me = ref.watch(authProvider).user;
    final s = S.of(context);

    return AsyncValueContent(
      value: courseAsync,
      builder: (course) {
        if (course == null) {
          return Scaffold(body: Center(child: Text(s.courseNotFound)));
        }

        final isOwner = me?.id == course.teacherId;
        final canReview = course.teacherId != null &&
            canLeaveProviderReview(me, providerId: course.teacherId!, providerRole: UserRole.teacher);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
                    ),
                  ),
                ),
                actions: [
                  walletAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (w) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(child: CoinBadge(amount: w.coins)),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (course.teacherName != null)
                            ProviderNameLink(
                              name: course.teacherName!,
                              providerId: course.teacherId,
                            ),
                          Text(
                            '★ ${course.ratingAvg} · ${s.totalEnrolled(course.enrollmentCount)}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _InfoChip(course.difficultyLabel),
                          _InfoChip(course.durationLabel),
                          _InfoChip(course.priceLabel),
                        ],
                      ),
                      if (course.progressPercent != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: (course.progressPercent! / 100).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: AppColors.surfaceVariant,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${course.progressPercent!.round()}%',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(course.description, style: const TextStyle(height: 1.6)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AppColors.coin, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.lessonRewardHint,
                                style: const TextStyle(fontSize: 12, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(s.curriculum, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 12),
                      AsyncValueContent(
                        value: modulesAsync,
                        builder: (modules) => Column(
                          children: modules
                              .map(
                                (m) => _ModuleSection(
                                  module: m,
                                  courseId: courseId,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (canReview) ...[
                        const SizedBox(height: 24),
                        ProviderReviewForm(
                          providerId: course.teacherId!,
                          providerName: course.teacherName ?? 'Instructor',
                          contextLabel: course.title,
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOwner) ...[
                    SmoothButton(
                      label: s.manageCourse,
                      icon: Icons.people_outline,
                      onPressed: () => context.push('/teacher/courses/$courseId'),
                    ),
                  ] else ...[
                    if (course.teacherId != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final teacherId = course.teacherId!;
                            ref.read(providerProfileProvider(teacherId).future).then((user) {
                              if (user != null && context.mounted) {
                                showContactProviderSheet(context: context, ref: ref, provider: user);
                              }
                            });
                          },
                          icon: const Icon(Icons.mail_outline_rounded, size: 18),
                          label: Text(s.contactProvider),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SmoothButton(
                      label: _enrollLabel(course, ref, s),
                      onPressed: () async {
                        final userId = ref.read(authProvider).user?.id;
                        if (userId == null) return;

                        final plan = ref.read(subscriptionProvider);
                        final alreadyEnrolled = course.progressPercent != null;

                        if (!alreadyEnrolled) {
                          final limit = plan.masterclassLimit;
                          if (limit != null) {
                            final count = await ref.read(databaseProvider).getEnrollmentCount(userId);
                            if (count >= limit) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(s.masterclassLimitReached(limit)),
                                    action: SnackBarAction(
                                      label: s.upgradeSubscription,
                                      onPressed: () => context.push('/profile/settings'),
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                        }

                        if (course.isFree || plan.includesPaidCourses) {
                          await ref.read(databaseProvider).enrollCourse(userId, courseId);
                          ref.invalidate(coursesProvider);
                          ref.invalidate(courseProvider(courseId));
                          ref.invalidate(enrolledCoursesProvider);
                          ref.invalidate(enrollmentCountProvider);
                          ref.invalidate(teacherEnrollmentStatsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  plan.includesPaidCourses && !course.isFree
                                      ? s.subscriptionCoversCourses
                                      : s.enrolledSuccess,
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        context.push(
                          '/checkout',
                          extra: PaymentCheckoutArgs(
                            title: course.title,
                            subtitle: course.teacherName,
                            amountCentimes: course.priceCents ?? 0,
                            purpose: PaymentPurpose.course,
                            itemId: courseId,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _enrollLabel(Course course, WidgetRef ref, S s) {
  if (course.progressPercent != null) return s.continueLearning;
  if (course.isFree) return s.enrollFree;
  final plan = ref.watch(subscriptionProvider);
  if (plan.includesPaidCourses) return s.enrollIncluded;
  return '${s.buy} ${course.priceLabel}';
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide.none,
    );
  }
}

class _ModuleSection extends ConsumerWidget {
  const _ModuleSection({required this.module, required this.courseId});

  final CourseModule module;
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(module.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...module.lessons.map((l) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                l.completed
                    ? Icons.check_circle
                    : l.hasVideo
                        ? Icons.play_circle_filled_rounded
                        : Icons.play_circle_outline,
                color: l.completed
                    ? AppColors.success
                    : l.hasVideo
                        ? AppColors.primary
                        : AppColors.textMuted,
                size: 22,
              ),
              title: Text(l.title, style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                l.hasVideo
                    ? (l.completed ? '${s.lessonDone} · Video' : 'Video lesson')
                    : (l.completed ? s.lessonDone : s.completeLesson),
                style: TextStyle(
                  fontSize: 11,
                  color: l.completed ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Text('${l.durationMinutes}m', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              onTap: () async {
                if (l.hasVideo) {
                  await context.push(
                    '/courses/$courseId/lessons/${l.id}',
                    extra: {
                      'title': l.title,
                      'videoAsset': l.videoAsset,
                      'completed': l.completed,
                    },
                  );
                  return;
                }
                if (l.completed) return;
                final userId = ref.read(authProvider).user?.id;
                if (userId == null) return;
                final result = await ref.read(databaseProvider).completeLesson(
                      userId: userId,
                      courseId: courseId,
                      lessonId: l.id,
                    );
                ref.invalidate(courseModulesProvider(courseId));
                ref.invalidate(courseProvider(courseId));
                ref.invalidate(coursesProvider);
                ref.invalidate(gamificationProvider);
                if (!context.mounted) return;
                if (result.alreadyDone) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.message ?? s.lessonDone)),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${result.message ?? s.lessonDone}  ${s.rewardSnack(result.coins, result.xp)}',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
