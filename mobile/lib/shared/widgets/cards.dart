import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/course_model.dart';
import 'smooth_components.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.compact = false,
  });

  final Course course;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        width: 160,
        child: SmoothCard(
          onTap: onTap,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(course: course, height: 80),
              const SizedBox(height: 10),
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                course.difficultyLabel,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return SmoothCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(course: course, width: 88, height: 88),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.difficultyLabel} · ${course.durationLabel} · ★ ${course.ratingAvg.toStringAsFixed(1)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (course.teacherName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.teacherName!,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.isFree
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.priceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: course.isFree ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    if (course.progressPercent != null) ...[
                      const Spacer(),
                      Text(
                        '${course.progressPercent!.round()}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                if (course.progressPercent != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: course.progressPercent! / 100,
                    backgroundColor: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.course,
    this.width,
    this.height = 88,
  });

  final Course course;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppColors.gradientPrimary,
      ),
      child: Center(
        child: Icon(
          _categoryIcon(course.category),
          color: Colors.white.withValues(alpha: 0.9),
          size: 28,
        ),
      ),
    );
  }

  IconData _categoryIcon(CourseCategory category) {
    switch (category) {
      case CourseCategory.softwareDev:
        return Icons.code;
      case CourseCategory.uiUx:
        return Icons.design_services;
      case CourseCategory.graphicDesign:
        return Icons.brush;
      case CourseCategory.digitalMarketing:
        return Icons.trending_up;
      case CourseCategory.cybersecurity:
        return Icons.security;
      case CourseCategory.ai:
        return Icons.psychology;
      case CourseCategory.languages:
        return Icons.translate;
      case CourseCategory.business:
        return Icons.business_center;
      case CourseCategory.other:
        return Icons.school;
    }
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onTap});

  final dynamic service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      service.providerName as String? ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service.description as String,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                service.priceLabel as String,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                '★ ${(service.ratingAvg as double).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${service.deliveryDays}d delivery',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final dynamic job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title as String,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            '${job.companyName} · ${job.remote ? 'Remote' : job.location ?? 'On-site'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _Tag(job.type as String),
              if (job.experienceLevel != null) _Tag(job.experienceLevel as String),
              _Tag(job.salaryLabel as String),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
