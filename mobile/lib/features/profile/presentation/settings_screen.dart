import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/profile_cover_header.dart';
import '../../../shared/widgets/smooth_button.dart';
import 'subscription_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final locale = ref.watch(localeProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (user != null)
            ProfileCoverHeader(
              coverUrl: profileCoverForUser(user),
              displayName: user.displayName,
              roleLabel: roleDisplayName(user.role),
              handle: '@${user.displayName.toLowerCase().replaceAll(' ', '_')}',
              avatarUrl: avatarForUser(user),
              bio: user.bio,
              onSettings: null,
              onShare: null,
            ),
          const SizedBox(height: 16),
          if (user != null && user.role != UserRole.client) ...[
            const SubscriptionSection(),
            const SizedBox(height: 12),
          ],
          ProfileSectionCard(
            title: s.language,
            icon: Icons.translate_rounded,
            iconColor: AppColors.accentBlue,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _LangChip(
                    label: 'Français',
                    selected: locale.languageCode == 'fr',
                    onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                  ),
                  const SizedBox(width: 8),
                  _LangChip(
                    label: 'العربية',
                    selected: locale.languageCode == 'ar',
                    onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
                  ),
                  const SizedBox(width: 8),
                  _LangChip(
                    label: 'English',
                    selected: locale.languageCode == 'en',
                    onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProfileSectionCard(
            title: s.aboutApp,
            icon: Icons.menu_book_outlined,
            iconColor: AppColors.accentOrange,
            child: Column(
              children: [
                _SettingsLinkTile(
                  icon: Icons.apartment_outlined,
                  iconBg: AppColors.pastelSky,
                  iconColor: AppColors.primary,
                  title: LegalContent.aboutUsTitle(locale),
                  onTap: () => context.push('/profile/about'),
                ),
                const Divider(height: 1),
                _SettingsLinkTile(
                  icon: Icons.policy_outlined,
                  iconBg: AppColors.pastelLavender,
                  iconColor: AppColors.accentPurple,
                  title: LegalContent.termsPrivacyTitle(locale),
                  onTap: () => context.push('/profile/terms'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (user?.role != UserRole.admin)
            ProfileSectionCard(
              title: s.reportUser,
              subtitle: s.reportUserSub,
              icon: Icons.flag_outlined,
              iconColor: AppColors.error,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag_outlined, color: AppColors.error, size: 20),
                ),
                title: Text(s.reportUser, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                onTap: () => context.push('/report'),
              ),
            ),
          if (user?.role != UserRole.admin) const SizedBox(height: 12),
          ProfileSectionCard(
            title: s.settings,
            subtitle: s.helpSupport,
            icon: Icons.tune_rounded,
            iconColor: AppColors.accentPurple,
            child: Column(
              children: [
                _PlaceholderTile(
                  icon: Icons.notifications_outlined,
                  iconBg: AppColors.pastelSky,
                  iconColor: AppColors.accentBlue,
                  title: s.notifications,
                ),
                const Divider(height: 1),
                _SettingsLinkTile(
                  icon: Icons.lock_outline_rounded,
                  iconBg: AppColors.pastelLavender,
                  iconColor: AppColors.accentPurple,
                  title: s.privacySecurity,
                  onTap: () => context.push('/profile/terms'),
                ),
                const Divider(height: 1),
                _PlaceholderTile(
                  icon: Icons.dark_mode_outlined,
                  iconBg: AppColors.pastelMint,
                  iconColor: AppColors.accentGreen,
                  title: s.appearance,
                ),
                const Divider(height: 1),
                _PlaceholderTile(
                  icon: Icons.help_outline_rounded,
                  iconBg: AppColors.pastelPeach,
                  iconColor: AppColors.accentOrange,
                  title: s.helpSupport,
                ),
                const Divider(height: 1),
                _SettingsLinkTile(
                  icon: Icons.info_outline_rounded,
                  iconBg: AppColors.surfaceVariant,
                  iconColor: AppColors.textSecondary,
                  title: s.aboutApp,
                  onTap: () => context.push('/profile/about'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SmoothButton(
              label: s.signOut,
              variant: SmoothButtonVariant.outline,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/welcome');
              },
            ),
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: s.contactInfo,
            icon: Icons.support_agent_outlined,
            iconColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    AppAssets.heroOffice,
                    height: 88,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 88,
                      color: AppColors.surfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ContactLine(icon: Icons.phone_outlined, text: AppConfig.hubPhone),
                const SizedBox(height: 6),
                _ContactLine(icon: Icons.email_outlined, text: AppConfig.hubEmail),
                const SizedBox(height: 6),
                _ContactLine(icon: Icons.location_on_outlined, text: AppConfig.hubAddress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: null,
    );
  }
}
