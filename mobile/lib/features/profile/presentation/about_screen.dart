import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/profile_cover_header.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final title = LegalContent.aboutUsTitle(locale);
    final body = LegalContent.aboutUsBody(locale);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              AppAssets.heroOffice,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ProfileSectionCard(
            title: title,
            icon: Icons.apartment_rounded,
            iconColor: AppColors.primary,
            child: Text(
              body,
              style: const TextStyle(fontSize: 14, height: 1.55, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
