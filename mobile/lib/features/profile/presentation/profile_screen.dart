import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/profile_cover_header.dart';
import 'profile_library_section.dart';
import 'profile_portfolio_section.dart';
import '../../../shared/widgets/share_sheet.dart';
import '../../../shared/widgets/smooth_components.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openSettings() => context.push('/profile/settings');

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);
    final plan = ref.watch(subscriptionProvider);
    final s = S.of(context);
    final progress = statsAsync.valueOrNull?.levelProgress ?? 0.75;
    final handle = '@${(user?.displayName ?? 'user').toLowerCase().replaceAll(' ', '_')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const AiAssistantFab(),
      body: AsyncValueContent(
        value: statsAsync,
        builder: (stats) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                children: [
            ProfileCoverHeader(
              coverUrl: user != null ? profileCoverForUser(user) : AppAssets.profileCoverLearner,
              displayName: user?.displayName ?? 'User',
              roleLabel: user != null ? roleDisplayName(user.role) : '',
              handle: handle,
              bio: user?.bio ?? s.defaultBio,
              avatarUrl: user != null ? avatarForUser(user) : AppAssets.avatar1,
              progress: progress,
              streak: stats.currentStreak,
              onShare: () => showShareSheet(context),
              onSettings: _openSettings,
            ),

            if (plan.hasPriorityReview || plan.hasMentoring) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (plan.hasPriorityReview)
                      _SubscriptionPerkTile(
                        icon: Icons.rate_review_outlined,
                        label: s.priorityReviewActive,
                        color: AppColors.accentPurple,
                      ),
                    if (plan.hasMentoring) ...[
                      if (plan.hasPriorityReview) const SizedBox(height: 8),
                      _SubscriptionPerkTile(
                        icon: Icons.support_agent_rounded,
                        label: s.vipMentoringTitle,
                        color: const Color(0xFFD97706),
                        onTap: () => context.push('/profile/settings'),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            ProfileSectionCard(
              title: s.streak,
              icon: Icons.insights_outlined,
              iconColor: AppColors.accentOrange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                  if (user?.role != UserRole.learner) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => context.push('/profile/feedback'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentPink,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          s.viewFeedback,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            ProfileSectionCard(
              title: s.moments,
              subtitle: s.publications,
              icon: Icons.public,
              iconColor: AppColors.accentPurple,
              action: user == null
                  ? null
                  : Text(
                      ref.watch(userPublicationsProvider(user.id)).maybeWhen(
                            data: (pubs) => '${pubs.length}',
                            orElse: () => '0',
                          ),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
              child: Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: user == null ? null : () => context.push('/profile/moments'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            AppAssets.learningDesk,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 52,
                              height: 52,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.photo_library_outlined, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user == null
                                ? s.noPublications
                                : ref.watch(userPublicationsProvider(user.id)).maybeWhen(
                                      data: (pubs) => pubs.isEmpty ? s.noPublications : pubs.first.body,
                                      orElse: () => s.noPublications,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Role-specific showcase (portfolio / learning journey / client activity) ──
            if (user != null) ProfilePortfolioSection(role: user.role, userId: user.id),

            const SizedBox(height: 18),

            // ── Courses, learning or booked services ──
            if (user != null) ProfileLibrarySection(role: user.role),

      

            // ── Learn Hub grid ──


            // ── Learn Hub grid ──
            if (user != null && user.role != UserRole.client)
              ProfileSectionCard(
                title: s.learnHubTitle,
                icon: Icons.laptop_mac_rounded,
                iconColor: AppColors.accentPurple,
                child: GridView.count(
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
              ),

            const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<InlineSpan> _insightSpans(String text) {
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

class _SubscriptionPerkTile extends StatelessWidget {
  const _SubscriptionPerkTile({
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
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
