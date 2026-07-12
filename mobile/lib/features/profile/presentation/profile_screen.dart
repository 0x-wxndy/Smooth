import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_button.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final s = S.of(context);
    final progress = statsAsync.valueOrNull?.levelProgress ?? 0.75;
    final handle = '@${(user?.displayName ?? 'user').toLowerCase().replaceAll(' ', '_')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AsyncValueContent(
        value: statsAsync,
        builder: (stats) => ListView(
          padding: EdgeInsets.zero,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, size: 14, color: AppColors.accentOrange),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.currentStreak}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.ios_share_rounded, size: 22),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Header: avatar + identity + Edit ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.05, 1.0),
                            strokeWidth: 4,
                            backgroundColor: AppColors.surfaceVariant,
                            color: AppColors.accentPurple,
                          ),
                        ),
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.pastelLavender,
                          backgroundImage: const NetworkImage(AppAssets.avatar1),
                          onBackgroundImageError: (_, __) {},
                          child: Text(
                            (user?.displayName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: AppColors.accentPurple,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.displayName ?? 'User',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  roleDisplayName(user.role),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(handle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          s.defaultBio,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientWarm,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            s.editProfile,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Insight banner ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 36,
                      child: Stack(
                        children: [
                          for (var i = 0; i < 3; i++)
                            Positioned(
                              left: i * 14.0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.surface,
                                backgroundImage: NetworkImage(
                                  [AppAssets.avatar2, AppAssets.avatar3, AppAssets.avatar4][i],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.textPrimary),
                          children: _insightSpans(s.insightBanner.replaceAll('{n}', '61')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFFBBF24)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              s.viewFeedback,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Moments ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: AppColors.accentPurple, size: 22),
                    const SizedBox(width: 8),
                    Text(s.moments, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        AppAssets.learningDesk,
                        width: 36,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 36,
                          height: 28,
                          color: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── VIP Benefits ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFDF2F8),
                      AppColors.pastelLavender.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text(s.vipBenefits, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _VipTable(s: s),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientWarm,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/learn'),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                s.exploreMasterclasses,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Learn Hub grid ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      AppColors.pastelLavender.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.learnHubTitle,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                        const Icon(Icons.laptop_mac_rounded, color: AppColors.accentPurple, size: 36),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.78,
                      children: [
                        _HubCat(icon: Icons.code, label: 'Python &\nFlutter', color: AppColors.primary, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.palette, label: 'Visual\nIdentity', color: AppColors.accentBlue, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.brush, label: 'Illustrator', color: AppColors.error, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.devices, label: 'UI/UX\nHub', color: AppColors.accentPurple, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.smart_toy, label: 'AI Dev &\nDesign', color: AppColors.accent, onTap: () => context.push('/ai')),
                        _HubCat(icon: Icons.storage, label: 'Backend\nSystems', color: AppColors.accentOrange, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.movie_filter, label: 'Motion\nGraphics', color: AppColors.accentPink, onTap: () => context.go('/learn')),
                        _HubCat(icon: Icons.menu_book, label: 'Design\nTheory', color: AppColors.navy, onTap: () => context.go('/learn')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language + sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.language, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Row(
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
                  const SizedBox(height: 16),
                  SmoothButton(
                    label: s.signOut,
                    variant: SmoothButtonVariant.outline,
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _insightSpans(String text) {
    // Emphasize numbers in orange
    final parts = text.split(RegExp(r'(\d+)'));
    final matches = RegExp(r'\d+').allMatches(text).map((m) => m.group(0)!).toList();
    final spans = <InlineSpan>[];
    var mi = 0;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (mi < matches.length && i < parts.length - 1) {
        spans.add(TextSpan(
          text: matches[mi++],
          style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.w800),
        ));
      }
    }
    return spans;
  }
}

class _VipTable extends StatelessWidget {
  const _VipTable({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 5, child: SizedBox()),
            Expanded(
              flex: 3,
              child: Text(
                s.freeCol,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                s.premiumCol,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.accentPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _VipRow(label: s.masterclassAccess, free: s.freePrompts, premium: s.unlimitedMaster, highlight: true),
        _VipRow(label: s.sourceFiles, free: '—', premiumCheck: true),
        _VipRow(label: s.priorityReview, free: '—', premiumCheck: true),
        _VipRow(label: s.webinars, free: '—', premiumCheck: true),
      ],
    );
  }
}

class _VipRow extends StatelessWidget {
  const _VipRow({
    required this.label,
    required this.free,
    this.premium,
    this.premiumCheck = false,
    this.highlight = false,
  });

  final String label;
  final String free;
  final String? premium;
  final bool premiumCheck;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.accentPurple : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: premiumCheck
                ? const Icon(Icons.check_circle, color: AppColors.accentPurple, size: 18)
                : Text(
                    premium ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPurple,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HubCat extends StatelessWidget {
  const _HubCat({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1.15),
          ),
        ],
      ),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
