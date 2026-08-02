import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/publication_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/profile_cover_header.dart';

class TeacherCourseDetailScreen extends ConsumerWidget {
  const TeacherCourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final courseAsync = ref.watch(courseProvider(courseId));
    final statsAsync = ref.watch(teacherEnrollmentStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(s.courseStudents)),
      body: AsyncValueContent(
        value: courseAsync,
        builder: (course) {
          if (course == null) {
            return Center(child: Text(s.courseNotFound));
          }

          return AsyncValueContent(
            value: statsAsync,
            builder: (stats) {
              final students = stats.students.where((st) => st.courseId == courseId).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  ProfileSectionCard(
                    title: course.title,
                    subtitle: '${course.difficultyLabel} · ${course.durationLabel}',
                    icon: Icons.menu_book_rounded,
                    iconColor: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.description, style: const TextStyle(height: 1.45, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MiniStat(
                              icon: Icons.people_outline,
                              label: s.enrolledStudents,
                              value: '${students.length}',
                              color: AppColors.accentBlue,
                            ),
                            const SizedBox(width: 10),
                            _MiniStat(
                              icon: Icons.star_outline_rounded,
                              label: s.averageRating,
                              value: course.ratingAvg.toStringAsFixed(1),
                              color: AppColors.accentOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileSectionCard(
                    title: s.enrolledStudents,
                    subtitle: students.isEmpty ? s.noEnrolledStudentsYet : s.studentsEnrolled(students.length),
                    icon: Icons.school_outlined,
                    iconColor: AppColors.accentPurple,
                    child: students.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              s.noEnrolledStudentsYet,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          )
                        : Column(
                            children: students.map((st) => _StudentRow(student: st, s: s)).toList(),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class EnrolledStudentRow extends StatelessWidget {
  const EnrolledStudentRow({super.key, required this.student});

  final EnrolledStudent student;

  @override
  Widget build(BuildContext context) {
    return _StudentRow(student: student, s: S.of(context));
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.s});

  final EnrolledStudent student;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySoft,
            backgroundImage: profileImageProvider(
              avatarForUserId(student.userId, avatarUrl: student.avatarUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  student.courseTitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (student.progressPercent / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${student.progressPercent.round()}%',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
