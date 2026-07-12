import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/smooth_components.dart';

class TeacherCoursesScreen extends ConsumerWidget {
  const TeacherCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final coursesAsync = ref.watch(myCoursesProvider);
    final walletAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myCourses),
        actions: [
          walletAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (w) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: CoinBadge(amount: w.coins)),
            ),
          ),
        ],
      ),
      body: AsyncValueContent(
        value: coursesAsync,
        builder: (courses) {
          if (courses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: s.noCoursesYet,
                subtitle: s.createFirstCourse,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: courses.length,
            itemBuilder: (_, i) => CourseCard(
              course: courses[i],
              onTap: () => context.push('/courses/${courses[i].id}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/post-course'),
        backgroundColor: AppColors.accentPurple,
        icon: const Icon(Icons.add),
        label: Text(s.newCourse),
      ),
    );
  }
}

class TeacherServicesScreen extends ConsumerWidget {
  const TeacherServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final servicesAsync = ref.watch(myServicesProvider);
    final walletAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myServices),
        actions: [
          IconButton(
            tooltip: s.claimRatingBonus,
            icon: const Icon(Icons.star_rounded, color: AppColors.coin),
            onPressed: () async {
              final userId = ref.read(authProvider).user?.id;
              if (userId == null) return;
              final result = await ref.read(databaseProvider).claimCreatorRatingBonus(userId);
              ref.invalidate(gamificationProvider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.alreadyDone
                        ? (result.message ?? s.bonusAlreadyClaimed)
                        : s.ratingBonusClaimed(AppConfig.ratingBonusCoins),
                  ),
                  backgroundColor: result.alreadyDone ? AppColors.warning : AppColors.success,
                ),
              );
            },
          ),
          walletAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (w) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: CoinBadge(amount: w.coins)),
            ),
          ),
        ],
      ),
      body: AsyncValueContent(
        value: servicesAsync,
        builder: (services) {
          if (services.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.design_services_outlined,
                title: s.noServicesYet,
                subtitle: s.createFirstService,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: services.length,
            itemBuilder: (_, i) => ServiceCard(
              service: services[i],
              onTap: () => context.push('/services/${services[i].id}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/post-service'),
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add),
        label: Text(s.newService),
      ),
    );
  }
}
