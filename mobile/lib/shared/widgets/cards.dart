import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/marketplace_model.dart';
import '../../shared/models/course_model.dart';
import 'smooth_components.dart';
import 'provider_name_link.dart';

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
        width: 148,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 128.0;
            return GestureDetector(
              onTap: onTap,
              child: _DarkCourseTile(
                course: course,
                height: h,
                radius: 14,
                showTitle: true,
              ),
            );
          },
        ),
      );
    }

    return SmoothCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: _DarkCourseTile(course: course, height: 88, radius: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.difficultyLabel} · ${course.durationLabel} · ★ ${course.ratingAvg.toStringAsFixed(1)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (course.teacherName != null) ...[
                  const SizedBox(height: 4),
                  ProviderNameLink(
                    name: course.teacherName!,
                    providerId: course.teacherId,
                    style: const TextStyle(color: AppColors.accentPurple, fontSize: 12, fontWeight: FontWeight.w700),
                    iconSize: 12,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PricePill(course: course),
                    if (course.progressPercent != null) ...[
                      const Spacer(),
                      Text(
                        '${course.progressPercent!.round()}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
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
                    color: AppColors.primary,
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

class _PricePill extends StatelessWidget {
  const _PricePill({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final free = Localizations.localeOf(context).languageCode == 'ar'
        ? 'مجاني'
        : Localizations.localeOf(context).languageCode == 'fr'
            ? 'Gratuit'
            : 'Free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: course.isFree
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.accentPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        course.priceLabelLocalized(free),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: course.isFree ? AppColors.success : AppColors.accentPurple,
        ),
      ),
    );
  }
}

class _DarkCourseTile extends StatelessWidget {
  const _DarkCourseTile({
    required this.course,
    this.height = 88,
    this.radius = 14,
    this.showTitle = false,
  });

  final Course course;
  final double height;
  final double radius;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CourseThumbImage(course: course),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navy.withValues(alpha: 0.2),
                    AppColors.navy.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTitle) ...[
                    const Spacer(),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const Spacer(),
                  Row(
                    children: [
                      Icon(_categoryIcon(course.category), color: Colors.white, size: 18),
                      const Spacer(),
                      const Icon(Icons.play_circle_fill, color: Colors.white70, size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

class _CourseThumbImage extends StatelessWidget {
  const _CourseThumbImage({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final thumb = course.thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http')) {
        return Image.network(
          thumb,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      }
      if (!kIsWeb) {
        return Image.file(
          File(thumb),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      }
    }
    return _fallback();
  }

  Widget _fallback() {
    return Image.network(
      AppAssets.courseThumb(course.category.name),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.navy),
    );
  }
}

class FreelancerMiniCard extends StatelessWidget {
  const FreelancerMiniCard({
    super.key,
    required this.name,
    required this.role,
    required this.rate,
    required this.rating,
    required this.avatarUrl,
    required this.tags,
    this.onTap,
  });

  final String name;
  final String role;
  final String rate;
  final double rating;
  final String avatarUrl;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pastelLavender,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tags.first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentPurple),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              '★ ${rating.toStringAsFixed(1)} · $rate',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accentOrange),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onTap});

  final FreelanceService service;
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
                radius: 22,
                backgroundColor: AppColors.accentOrange.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: AppColors.accentOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    ProviderNameLink(
                      name: service.providerName ?? '',
                      providerId: service.providerId,
                      style: const TextStyle(fontSize: 12),
                      iconSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                service.priceLabel,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                '★ ${service.ratingAvg.toStringAsFixed(2)}',
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
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onApply,
    this.applied = false,
  });

  final dynamic job;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final bool applied;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SmoothCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title as String,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
          if (onApply != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: applied ? null : onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: applied ? AppColors.surfaceVariant : AppColors.primary,
                  foregroundColor: applied ? AppColors.textSecondary : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(applied ? s.alreadyApplied : s.postuler),
              ),
            ),
          ],
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
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
