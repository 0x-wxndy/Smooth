import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/user_model.dart';

class OnboardingTip {
  const OnboardingTip({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

List<OnboardingTip> onboardingTipsForRole(UserRole role, S s) {
  return switch (role) {
    UserRole.learner => [
        OnboardingTip(
          icon: Icons.menu_book_rounded,
          color: AppColors.primary,
          title: s.onboardingLearner1Title,
          body: s.onboardingLearner1Body,
        ),
        OnboardingTip(
          icon: Icons.storefront_rounded,
          color: AppColors.accentBlue,
          title: s.onboardingLearner2Title,
          body: s.onboardingLearner2Body,
        ),
        OnboardingTip(
          icon: Icons.smart_toy_rounded,
          color: AppColors.accentPurple,
          title: s.onboardingLearner3Title,
          body: s.onboardingLearner3Body,
        ),
        OnboardingTip(
          icon: Icons.person_rounded,
          color: AppColors.accentOrange,
          title: s.onboardingLearner4Title,
          body: s.onboardingLearner4Body,
        ),
      ],
    UserRole.teacher => [
        OnboardingTip(
          icon: Icons.dashboard_rounded,
          color: AppColors.primary,
          title: s.onboardingTeacher1Title,
          body: s.onboardingTeacher1Body,
        ),
        OnboardingTip(
          icon: Icons.add_circle_outline_rounded,
          color: AppColors.accentPurple,
          title: s.onboardingTeacher2Title,
          body: s.onboardingTeacher2Body,
        ),
        OnboardingTip(
          icon: Icons.apartment_rounded,
          color: AppColors.accentGreen,
          title: s.onboardingTeacher3Title,
          body: s.onboardingTeacher3Body,
        ),
        OnboardingTip(
          icon: Icons.work_outline_rounded,
          color: AppColors.accentBlue,
          title: s.onboardingTeacher4Title,
          body: s.onboardingTeacher4Body,
        ),
      ],
    UserRole.client => [
        OnboardingTip(
          icon: Icons.storefront_rounded,
          color: AppColors.accentBlue,
          title: s.onboardingClient1Title,
          body: s.onboardingClient1Body,
        ),
        OnboardingTip(
          icon: Icons.apartment_rounded,
          color: AppColors.accentGreen,
          title: s.onboardingClient2Title,
          body: s.onboardingClient2Body,
        ),
        OnboardingTip(
          icon: Icons.work_outline_rounded,
          color: AppColors.accentOrange,
          title: s.onboardingClient3Title,
          body: s.onboardingClient3Body,
        ),
        OnboardingTip(
          icon: Icons.menu_book_rounded,
          color: AppColors.primary,
          title: s.onboardingClient4Title,
          body: s.onboardingClient4Body,
        ),
      ],
    UserRole.admin => [
        OnboardingTip(
          icon: Icons.analytics_outlined,
          color: AppColors.primary,
          title: s.onboardingAdmin1Title,
          body: s.onboardingAdmin1Body,
        ),
        OnboardingTip(
          icon: Icons.people_outline_rounded,
          color: AppColors.accentBlue,
          title: s.onboardingAdmin2Title,
          body: s.onboardingAdmin2Body,
        ),
        OnboardingTip(
          icon: Icons.flag_outlined,
          color: AppColors.error,
          title: s.onboardingAdmin3Title,
          body: s.onboardingAdmin3Body,
        ),
        OnboardingTip(
          icon: Icons.mail_outline_rounded,
          color: AppColors.accentGreen,
          title: s.onboardingAdmin4Title,
          body: s.onboardingAdmin4Body,
        ),
      ],
  };
}
