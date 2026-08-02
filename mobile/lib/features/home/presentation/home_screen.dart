import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/hub_hero.dart';
import '../../../shared/widgets/back_to_menu_bar.dart';
import '../../../shared/widgets/dashboard_section.dart';
import '../../../shared/models/course_model.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final statsAsync = ref.watch(gamificationProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      floatingActionButton: const AiAssistantFab(),
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
          final freeCourses = courses.where((c) => c.isFree).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: BackToMenuBar()),
              SliverToBoxAdapter(
                child: HubHeroShell(
                  brandTitle: s.appName,
                  heroTitle: s.homeHeroTitle,
                  heroSubtitle: s.homeHeroSubtitle,
                  coverUrl: AppAssets.heroOffice,
                  coverHeight: 272,
                  trailing: statsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stats) => LevelBadge(
                      level: stats.level,
                      label: stats.level <= 3 ? s.rookie : 'Lv.${stats.level}',
                    ),
                  ),
                  primaryCta: HubCta(
                    label: s.startLearningFree,
                    onPressed: () => context.go('/learn'),
                  ),
                  secondaryCta: HubCta(
                    label: s.bookInHub,
                    onPressed: () => context.push('/hub'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HubContentSheet(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: statsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (stats) => DashboardSectionCard(
                            title: s.streak,
                            icon: Icons.emoji_events_outlined,
                            iconColor: AppColors.accentOrange,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SoftMetricCard(
                                    background: AppColors.pastelMint,
                                    icon: Icons.local_fire_department_rounded,
                                    iconColor: AppColors.warning,
                                    label: s.streak,
                                    value: '${stats.currentStreak}d',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SoftMetricCard(
                                    background: AppColors.pastelPeach,
                                    icon: Icons.monetization_on_rounded,
                                    iconColor: AppColors.coin,
                                    label: s.coins,
                                    value: '${stats.coins}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SoftMetricCard(
                                    background: AppColors.pastelLavender,
                                    icon: Icons.bolt_rounded,
                                    iconColor: AppColors.accentPurple,
                                    label: s.xp,
                                    value: '${stats.xp}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (continueCourse != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: DashboardSectionCard(
                            title: s.continueLearning,
                            icon: Icons.play_circle_outline,
                            iconColor: AppColors.primary,
                            child: CourseCard(
                              course: continueCourse,
                              onTap: () => context.push('/courses/${continueCourse!.id}'),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: DashboardSectionCard(
                          title: s.freeLibrary,
                          subtitle: s.freeLibrarySub,
                          icon: Icons.school_rounded,
                          iconColor: AppColors.primary,
                          child: SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: freeCourses.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => CourseCard(
                                course: freeCourses[i],
                                compact: true,
                                onTap: () => context.push('/courses/${freeCourses[i].id}'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: DashboardSectionCard(
                          title: s.categories,
                          icon: Icons.grid_view_rounded,
                          iconColor: AppColors.accentBlue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: AppConstants.categories
                                      .map(
                                        (c) => SmoothChipFilter(
                                          label: c.$1,
                                          selected: false,
                                          onTap: () => context.go('/learn'),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _HubTile(
                                      icon: Icons.auto_awesome,
                                      label: s.aiAssistant,
                                      color: AppColors.accentPurple,
                                      onTap: () => context.push('/ai'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _HubTile(
                                      icon: Icons.videogame_asset_rounded,
                                      label: s.games,
                                      color: AppColors.accentPink,
                                      onTap: () => context.push('/games'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SmoothButton(
                                label: s.exploreMarket,
                                variant: SmoothButtonVariant.outline,
                                onPressed: () => context.go('/market'),
                              ),
                            ],
                          ),
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

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
