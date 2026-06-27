import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/models/course_model.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CoinBadge(amount: stats.coins),
            ),
          ),
        ],
      ),
      body: AsyncValueContent<List<Course>>(
        value: coursesAsync,
        builder: (courses) {
          Course? continueCourse;
          for (final c in courses) {
            if (c.progressPercent != null) {
              continueCourse = c;
              break;
            }
          }
          continueCourse ??= courses.isNotEmpty ? courses.first : null;
          final inProgress = continueCourse;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              statsAsync.when(
                loading: () => const SizedBox(height: 48),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, ${user?.displayName ?? 'Learner'}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${stats.level} · ${stats.xp} XP',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        LevelBadge(level: stats.level),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: stats.levelProgress,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              if (inProgress != null) ...[
                const SectionHeader(title: 'Continue learning'),
                CourseCard(
                  course: inProgress,
                  onTap: () => context.push('/courses/${inProgress.id}'),
                ),
                const SizedBox(height: 20),
              ],
              const SectionHeader(title: 'Categories'),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: AppConstants.categories
                      .map((c) => SmoothChipFilter(label: c.$1, selected: false, onTap: () {}))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Recommended for you',
                actionLabel: 'See all',
                onAction: () => context.go('/learn'),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => CourseCard(
                    course: courses[i],
                    compact: true,
                    onTap: () => context.push('/courses/${courses[i].id}'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _QuickActions(onAi: () => context.push('/ai'), onGames: () => context.push('/games')),
              const SizedBox(height: 16),
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => SmoothCard(
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.warning, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${stats.currentStreak}-day streak!', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const Text(
                              'Keep learning to earn bonus coins',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onAi, required this.onGames});

  final VoidCallback onAi;
  final VoidCallback onGames;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.auto_awesome,
            label: 'AI Assistant',
            gradient: AppColors.gradientPrimary,
            onTap: onAi,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.videogame_asset_outlined,
            label: 'Games',
            color: AppColors.secondary,
            onTap: onGames,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color?.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(16),
          border: gradient == null ? Border.all(color: AppColors.border) : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: gradient != null ? Colors.white : color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: gradient != null ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
