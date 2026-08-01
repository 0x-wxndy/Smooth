import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
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
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null && user.role != UserRole.client) ...[
            const SubscriptionSection(),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.language, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
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
                    ],
                  ),
                ),
                if (user?.role != UserRole.admin) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flag_outlined, color: AppColors.error, size: 20),
                    ),
                    title: Text(s.reportUser, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(s.reportUserSub, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: () => context.push('/report'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PlaceholderSettingsCard(s: s),
          const SizedBox(height: 16),
          SmoothButton(
            label: s.signOut,
            variant: SmoothButtonVariant.outline,
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.contactInfo,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
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
class _PlaceholderSettingsCard extends StatelessWidget {
  const _PlaceholderSettingsCard({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlaceholderTile(
            icon: Icons.notifications_outlined,
            iconBg: AppColors.pastelSky,
            iconColor: AppColors.accentBlue,
            title: s.notifications,
          ),
          const Divider(height: 1),
          _PlaceholderTile(
            icon: Icons.lock_outline_rounded,
            iconBg: AppColors.pastelLavender,
            iconColor: AppColors.accentPurple,
            title: s.privacySecurity,
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
          _PlaceholderTile(
            icon: Icons.info_outline_rounded,
            iconBg: AppColors.surfaceVariant,
            iconColor: AppColors.textSecondary,
            title: s.aboutApp,
          ),
        ],
      ),
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
