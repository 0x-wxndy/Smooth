import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';

class ProfileLibrarySection extends ConsumerWidget {
  const ProfileLibrarySection({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (role == UserRole.admin) return const SizedBox.shrink();

    final seeAllRoute = switch (role) {
      UserRole.teacher => '/teacher/courses',
      UserRole.client => '/market',
      _ => '/learn',
    };
    final s = S.of(context);
    final showOwned = role == UserRole.teacher;
    final coursesAsync = ref.watch(showOwned ? myCoursesProvider : enrolledCoursesProvider);
    final servicesAsync = ref.watch(showOwned ? myServicesProvider : bookedServicesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.profileLibraryTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(seeAllRoute),
                  child: Text(s.seeAll, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (role != UserRole.client) ...[
              Text(s.myCourses, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              AsyncValueContent(
                value: coursesAsync,
                builder: (courses) {
                  if (courses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        showOwned ? s.noCoursesYet : s.noEnrolledCourses,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    );
                  }
                  return Column(
                    children: courses
                        .take(3)
                        .map(
                          (course) => CourseCard(
                            course: course,
                            onTap: () => context.push('/courses/${course.id}'),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
            Text(s.myServices, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            AsyncValueContent(
              value: servicesAsync,
              builder: (services) {
                if (services.isEmpty) {
                  return Text(
                    showOwned ? s.noServicesYet : s.noBookedServices,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  );
                }
                return Column(
                  children: services
                      .take(3)
                      .map(
                        (svc) => ServiceCard(
                          service: svc,
                          onTap: () => context.push('/services/${svc.id}'),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
