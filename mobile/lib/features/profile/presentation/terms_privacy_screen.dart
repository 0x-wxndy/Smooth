import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/profile_cover_header.dart';

class TermsPrivacyScreen extends ConsumerWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final title = LegalContent.termsPrivacyTitle(locale);
    final sections = LegalContent.termsSections(locale);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final section = sections[i];
          return ProfileSectionCard(
            title: section.title,
            icon: Icons.gavel_outlined,
            iconColor: AppColors.accentPurple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.bullets
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
