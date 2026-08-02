import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/hub_hero.dart';
import '../../../shared/widgets/back_to_menu_bar.dart';
import '../../../shared/widgets/dashboard_section.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../teacher/presentation/teacher_course_detail_screen.dart';

class TeacherDashboardTab extends ConsumerWidget {
  const TeacherDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);
    final myCoursesAsync = ref.watch(myCoursesProvider);
    final myServicesAsync = ref.watch(myServicesProvider);
    final jobsAsync = ref.watch(jobsProvider(null));
    final enrollmentAsync = ref.watch(teacherEnrollmentStatsProvider);

    final courseCount = myCoursesAsync.maybeWhen(data: (c) => '${c.length}', orElse: () => '—');
    final serviceCount = myServicesAsync.maybeWhen(data: (c) => '${c.length}', orElse: () => '—');

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: BackToMenuBar()),
          SliverToBoxAdapter(
            child: HubHeroShell(
              brandTitle: s.creatorStudio,
              greeting: '${s.welcome.replaceAll('!', '')}, ${user?.displayName ?? 'Creator'}',
              heroTitle: s.teacherHeroTitle,
              heroSubtitle: s.teacherHeroSubtitle,
              coverUrl: AppAssets.learningDesk,
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
                label: s.postCourse,
                icon: Icons.menu_book_rounded,
                onPressed: () => context.push('/teacher/post-course'),
              ),
              secondaryCta: HubCta(
                label: s.hubFacilities,
                icon: Icons.meeting_room_outlined,
                onPressed: () => context.push('/hub'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubContentSheet(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (stats) => DashboardSectionCard(
                        title: s.creatorStudio,
                        icon: Icons.dashboard_customize_outlined,
                        iconColor: AppColors.accentPurple,
                        child: Row(
                          children: [
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
                                icon: Icons.menu_book_rounded,
                                iconColor: AppColors.accentPurple,
                                label: s.courses,
                                value: courseCount,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SoftMetricCard(
                                background: AppColors.pastelMint,
                                icon: Icons.design_services_rounded,
                                iconColor: AppColors.accentGreen,
                                label: s.services,
                                value: serviceCount,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AsyncValueContent(
                      value: enrollmentAsync,
                      builder: (enrollment) => DashboardSectionCard(
                        title: s.myStudents,
                        subtitle: enrollment.totalStudents == 0
                            ? s.noEnrolledStudentsYet
                            : s.totalEnrolled(enrollment.totalStudents),
                        icon: Icons.people_outline,
                        iconColor: AppColors.accentBlue,
                        action: enrollment.students.isEmpty
                            ? null
                            : TextButton(
                                onPressed: () => context.go('/teacher/courses?tab=students'),
                                child: Text(s.seeAll, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                        child: enrollment.students.isEmpty
                            ? Text(
                                s.noEnrolledStudentsYet,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              )
                            : Column(
                                children: enrollment.students
                                    .take(5)
                                    .map((st) => EnrolledStudentRow(student: st))
                                    .toList(),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardSectionCard(
                      title: s.creatorActions,
                      icon: Icons.add_circle_outline,
                      iconColor: AppColors.accentPurple,
                      child: Column(
                        children: [
                          _ActionRow(
                            icon: Icons.add_circle_outline,
                            color: AppColors.accentPurple,
                            title: s.postCourse,
                            subtitle: '+${AppConfig.postCourseCoins} ${s.coins.toLowerCase()}',
                            onTap: () => context.push('/teacher/post-course'),
                          ),
                          const Divider(height: 20),
                          _ActionRow(
                            icon: Icons.design_services,
                            color: AppColors.accentOrange,
                            title: s.postService,
                            subtitle: '+${AppConfig.postServiceCoins} ${s.coins.toLowerCase()}',
                            onTap: () => context.push('/teacher/post-service'),
                          ),
                          const Divider(height: 20),
                          _ActionRow(
                            icon: Icons.storefront_outlined,
                            color: AppColors.primary,
                            title: s.exploreMarket,
                            subtitle: s.creatorMarketTitle,
                            onTap: () => context.go('/market'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardSectionCard(
                      title: s.jobOffers,
                      icon: Icons.work_outline_rounded,
                      iconColor: AppColors.accentBlue,
                      action: TextButton(
                        onPressed: () => context.go('/jobs'),
                        child: Text(s.seeAll, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      child: AsyncValueContent(
                        value: jobsAsync,
                        builder: (jobs) => Column(
                          children: jobs
                              .take(3)
                              .map((j) => JobCard(job: j, onTap: () => context.go('/jobs')))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardSectionCard(
                      title: s.myCourses,
                      icon: Icons.menu_book_outlined,
                      iconColor: AppColors.primary,
                      action: TextButton(
                        onPressed: () => context.go('/teacher/courses'),
                        child: Text(s.seeAll, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      child: AsyncValueContent(
                        value: myCoursesAsync,
                        builder: (courses) {
                          if (courses.isEmpty) {
                            return Text(s.noCoursesYet, style: const TextStyle(color: AppColors.textSecondary));
                          }
                          return Column(
                            children: courses
                                .take(2)
                                .map(
                                  (c) => _TeacherCourseRow(
                                    course: c,
                                    studentCount: enrollmentAsync.maybeWhen(
                                      data: (e) => e.students.where((st) => st.courseId == c.id).length,
                                      orElse: () => 0,
                                    ),
                                    onTap: () => context.push('/teacher/courses/${c.id}'),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherCourseRow extends StatelessWidget {
  const _TeacherCourseRow({
    required this.course,
    required this.studentCount,
    required this.onTap,
  });

  final Course course;
  final int studentCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    s.studentsEnrolled(studentCount),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
