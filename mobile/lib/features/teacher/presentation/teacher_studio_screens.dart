import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/publication_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/smooth_components.dart';
import 'teacher_course_detail_screen.dart';

/// Teacher studio with courses + students tabs.
class TeacherCoursesScreen extends ConsumerStatefulWidget {
  const TeacherCoursesScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends ConsumerState<TeacherCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.courses),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: s.manageCoursesTab, icon: const Icon(Icons.menu_book_outlined, size: 20)),
            Tab(text: s.manageStudentsTab, icon: const Icon(Icons.people_outline, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TeacherCoursesTab(),
          _TeacherStudentsTab(),
        ],
      ),
    );
  }
}

class _TeacherCoursesTab extends ConsumerWidget {
  const _TeacherCoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final coursesAsync = ref.watch(myCoursesProvider);
    final enrollmentAsync = ref.watch(teacherEnrollmentStatsProvider);

    return AsyncValueContent(
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
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: courses.length,
              itemBuilder: (_, i) {
                final course = courses[i];
                final studentCount = enrollmentAsync.maybeWhen(
                  data: (stats) => stats.students.where((st) => st.courseId == course.id).length,
                  orElse: () => 0,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseCard(
                      course: course,
                      onTap: () => context.push('/teacher/courses/${course.id}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        s.studentsEnrolled(studentCount),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/teacher/post-course'),
                backgroundColor: AppColors.accentPurple,
                icon: const Icon(Icons.add),
                label: Text(s.newCourse),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TeacherStudentsTab extends ConsumerWidget {
  const _TeacherStudentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final enrollmentAsync = ref.watch(teacherEnrollmentStatsProvider);

    return AsyncValueContent(
      value: enrollmentAsync,
      builder: (stats) {
        if (stats.students.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: EmptyState(
              icon: Icons.people_outline,
              title: s.noEnrolledStudentsYet,
              subtitle: s.manageStudentsTab,
            ),
          );
        }

        final byCourse = <String, List<EnrolledStudent>>{};
        for (final st in stats.students) {
          byCourse.putIfAbsent(st.courseId, () => []).add(st);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
              ),
              child: Text(
                s.totalEnrolled(stats.totalStudents),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            ...byCourse.entries.map((entry) {
              final courseTitle = entry.value.first.courseTitle;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            courseTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/teacher/courses/${entry.key}'),
                          child: Text(s.seeAll, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map((st) => EnrolledStudentRow(student: st)),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        );
      },
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
