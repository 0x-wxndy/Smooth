import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_button.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));

    return AsyncValueContent(
      value: courseAsync,
      builder: (course) {
        if (course == null) {
          return const Scaffold(body: Center(child: Text('Course not found')));
        }

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
                  IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
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
                      Text(
                        '${course.teacherName ?? 'Instructor'} · ★ ${course.ratingAvg} · ${course.enrollmentCount} students',
                        style: const TextStyle(color: AppColors.textSecondary),
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
                      const SizedBox(height: 20),
                      Text(course.description, style: const TextStyle(height: 1.6)),
                      const SizedBox(height: 24),
                      const Text('Curriculum', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 12),
                      AsyncValueContent(
                        value: modulesAsync,
                        builder: (modules) => Column(
                          children: modules.map((m) => _ModuleSection(module: m)).toList(),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SmoothButton(
                label: course.isFree ? 'Enroll — Free' : 'Buy ${course.priceLabel}',
                onPressed: () async {
                  final userId = ref.read(authProvider).user?.id;
                  if (userId != null) {
                    await ref.read(databaseProvider).enrollCourse(userId, courseId);
                    ref.invalidate(coursesProvider);
                    ref.invalidate(courseProvider(courseId));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enrolled successfully!')),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
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

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({required this.module});

  final dynamic module;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(module.title as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...(module.lessons as List).map((l) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  (l.completed as bool) ? Icons.check_circle : Icons.play_circle_outline,
                  color: (l.completed as bool) ? AppColors.success : AppColors.textMuted,
                  size: 22,
                ),
                title: Text(l.title as String, style: const TextStyle(fontSize: 14)),
                trailing: Text('${l.durationMinutes}m', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              )),
        ],
      ),
    );
  }
}
