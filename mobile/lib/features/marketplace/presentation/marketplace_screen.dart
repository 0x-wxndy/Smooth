import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../hub/presentation/hub_screens.dart';
import '../../profile/presentation/provider_profile_screen.dart';
import '../../profile/presentation/profile_portfolio_section.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';

class MarketTab extends ConsumerStatefulWidget {
  const MarketTab({super.key});

  @override
  ConsumerState<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends ConsumerState<MarketTab> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final role = ref.watch(authProvider).user?.role ?? UserRole.learner;
    final servicesAsync = ref.watch(servicesProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final jobsAsync = ref.watch(jobsProvider(null));
    final walletAsync = ref.watch(gamificationProvider);
    final myCoursesAsync = ref.watch(myCoursesProvider);
    final myServicesAsync = ref.watch(myServicesProvider);

    return Scaffold(
      floatingActionButton: _fabForRole(context, role, s),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _MarketHeader(s: s, walletAsync: walletAsync),
            const SizedBox(height: 14),
            SmoothSearchField(hint: s.searchHint, readOnly: true, onTap: () => context.push('/search')),
            const SizedBox(height: 14),

            if (role == UserRole.learner) ...[
              _FreeLibrarySection(coursesAsync: coursesAsync, s: s),
              const SizedBox(height: 16),
              _PremiumCoursesSection(coursesAsync: coursesAsync, s: s),
            ],

            if (role == UserRole.teacher) ...[
             _FreelancersSection(s: s),
              const SizedBox(height: 14),
              const HubFacilitiesPromo(),
              const SizedBox(height: 14),
              _AnnouncementsSection(s: s),
              const SizedBox(height: 14),
              _CreatorEarningsBanner(
                s: s,
                walletAsync: walletAsync,
                onClaimBonus: () => _claimBonus(context),
              ),
              const SizedBox(height: 14),
              _MyListingsSection(
                s: s,
                myCoursesAsync: myCoursesAsync,
                myServicesAsync: myServicesAsync,
              ),
              _JobsOffersSection(jobsAsync: jobsAsync, s: s),
              _ProjectsSection(s: s, title: s.clientRequests),
              _AllServicesSection(servicesAsync: servicesAsync, s: s),
            ],

            if (role == UserRole.client) ...[
               _FreelancersSection(s: s),
              const SizedBox(height: 14),
              const HubFacilitiesPromo(),
              const SizedBox(height: 14),
              _AnnouncementsSection(s: s),
              const SizedBox(height: 14),
              _ClientHero(s: s),
              const SizedBox(height: 14),
              _AllServicesSection(servicesAsync: servicesAsync, s: s),
              _ProjectsSection(s: s, title: s.pendingProjects),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _fabForRole(BuildContext context, UserRole role, S s) {
    switch (role) {
      case UserRole.teacher:
        return FloatingActionButton.extended(
          onPressed: () => _showCreatorActions(context, s),
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(s.offerService, style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      case UserRole.client:
        return FloatingActionButton.extended(
          onPressed: () {
            final userId = ref.read(authProvider).user?.id;
            if (userId == null) return;
            showNewPublicationSheet(
              context: context,
              ref: ref,
              userId: userId,
              defaultKind: 'offer',
            );
          },
          backgroundColor: AppColors.accentGreen,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.post_add_rounded),
          label: Text(s.postAJob, style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      case UserRole.learner:
        return null;
      case UserRole.admin:
        return null;
    }
  }

  void _showCreatorActions(BuildContext context, S s) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.creatorActions, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            Text(s.creatorEarnHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.pastelLavender, child: Icon(Icons.menu_book, color: AppColors.accentPurple)),
              title: Text(s.postCourse),
              subtitle: Text('+${AppConfig.postCourseCoins} ${s.coins.toLowerCase()}'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/teacher/post-course');
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.pastelPeach, child: Icon(Icons.design_services, color: AppColors.accentOrange)),
              title: Text(s.postService),
              subtitle: Text('+${AppConfig.postServiceCoins} ${s.coins.toLowerCase()}'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/teacher/post-service');
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.pastelMint, child: Icon(Icons.work, color: AppColors.accentGreen)),
              title: Text(s.browseJobs),
              subtitle: Text(s.applyJobsHint),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/jobs');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimBonus(BuildContext context) async {
    final s = S.of(context);
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    final result = await ref.read(databaseProvider).claimCreatorRatingBonus(userId);
    ref.invalidate(gamificationProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.alreadyDone
              ? (result.message ?? s.bonusAlreadyClaimed)
              : s.ratingBonusClaimed(AppConfig.ratingBonusCoins),
        ),
        backgroundColor: result.alreadyDone ? AppColors.warning : AppColors.success,
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  const _MarketHeader({required this.s, required this.walletAsync});
  final S s;
  final AsyncValue<GamificationStats> walletAsync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront_rounded, color: AppColors.accentPurple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(s.marketplaceTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
        walletAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (w) => CoinBadge(amount: w.coins),
        ),
      ],
    );
  }
}

class _CreatorEarningsBanner extends StatelessWidget {
  const _CreatorEarningsBanner({
    required this.s,
    required this.walletAsync,
    required this.onClaimBonus,
  });
  final S s;
  final AsyncValue<GamificationStats> walletAsync;
  final VoidCallback onClaimBonus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.creatorMarketTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(s.creatorEarnHint, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.35)),
          const SizedBox(height: 12),
          Row(
            children: [
              walletAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (w) => Text(
                  '${w.coins} ${s.coins} · ${w.xp} XP',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClaimBonus,
                style: TextButton.styleFrom(foregroundColor: AppColors.coin, backgroundColor: Colors.white12),
                child: Text(s.claimRatingBonus, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientHero extends ConsumerWidget {
  const _ClientHero({required this.s});
  final S s;

  @override
    Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.clientMarketTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(s.clientMarketSub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final userId = ref.read(authProvider).user?.id;
                    if (userId == null) return;
                    showNewPublicationSheet(
                      context: context,
                      ref: ref,
                      userId: userId,
                      defaultKind: 'offer',
                    );
                  },
                child: Text(s.postAJob),
              ),
            ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentGreen),
                  child: Text(s.hireTalent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyListingsSection extends StatelessWidget {
  const _MyListingsSection({
    required this.s,
    required this.myCoursesAsync,
    required this.myServicesAsync,
  });
  final S s;
  final AsyncValue<List<Course>> myCoursesAsync;
  final AsyncValue<List<FreelanceService>> myServicesAsync;

  @override
  Widget build(BuildContext context) {
    return BorderedSection(
      borderColor: AppColors.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: s.myListings,
            actionLabel: s.seeAll,
            onAction: () => context.go('/teacher/courses'),
          ),
          myCoursesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (courses) => Text(
              '${courses.length} ${s.courses.toLowerCase()}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          myServicesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (services) => Text(
              '${services.length} ${s.services.toLowerCase()}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/teacher/post-course'),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: Text(s.postCourse, style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/teacher/post-service'),
                  icon: const Icon(Icons.design_services, size: 18),
                  label: Text(s.postService, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobsOffersSection extends StatelessWidget {
  const _JobsOffersSection({required this.jobsAsync, required this.s});
  final AsyncValue<List<JobPosting>> jobsAsync;
  final S s;

  @override
  Widget build(BuildContext context) {
    return BorderedSection(
      borderColor: AppColors.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: s.jobOffers,
            actionLabel: s.seeAll,
            onAction: () => context.go('/jobs'),
            icon: Icons.work_outline,
            iconColor: AppColors.accentBlue,
          ),
          Text(s.applyJobsHint, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          AsyncValueContent(
            value: jobsAsync,
            builder: (jobs) => Column(
              children: jobs.take(3).map((j) => JobCard(job: j, onTap: () => context.go('/jobs'))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeLibrarySection extends StatelessWidget {
  const _FreeLibrarySection({required this.coursesAsync, required this.s});
  final AsyncValue<List<Course>> coursesAsync;
  final S s;

  @override
  Widget build(BuildContext context) {
    return AsyncValueContent(
      value: coursesAsync,
      builder: (courses) {
        final free = courses.where((c) => c.isFree).take(6).toList();
        return BorderedSection(
          borderColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.school_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.freeLibrary, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: free.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => CourseCard(
                    course: free[i],
                    compact: true,
                    onTap: () => context.push('/courses/${free[i].id}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FreelancersSection extends ConsumerWidget {
  const _FreelancersSection({required this.s});
  final S s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProvidersProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AsyncValueContent(
        value: featuredAsync,
        builder: (providers) {
          if (providers.isEmpty) return const SizedBox.shrink();
          return BorderedSection(
            borderColor: AppColors.accentOrange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_rounded, color: AppColors.accentOrange),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.featuredFreelancers, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    TextButton(
                      onPressed: () => context.push('/providers'),
                      child: Text(s.seeAll, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final p = providers[i];
                      return FreelancerMiniCard(
                        name: p.displayName,
                        role: p.headline,
                        rate: p.hourlyLabel(s.perHour),
                        rating: p.ratingAvg,
                        avatarUrl: p.avatarUrl ?? featuredAvatarForIndex(i),
                        tags: p.tags,
                        onTap: () => context.push('/providers/${p.userId}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementsSection extends ConsumerWidget {
  const _AnnouncementsSection({required this.s});
  final S s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return AsyncValueContent(
      value: announcementsAsync,
      builder: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return BorderedSection(
          borderColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(s.announcements, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              ...items.take(3).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(p.body, style: const TextStyle(fontSize: 13, height: 1.35)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.s, this.title});
  final S s;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BorderedSection(
      borderColor: AppColors.accentGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppColors.accentGreen, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title ?? s.pendingProjects, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProjectRequestTile(icon: Icons.palette_outlined, title: s.projectVisual, budget: Money.format(6750000), color: AppColors.accentGreen),
          const SizedBox(height: 10),
          _ProjectRequestTile(icon: Icons.android_rounded, title: s.projectAndroid, budget: Money.format(16200000), color: AppColors.accentBlue),
        ],
      ),
    );
  }
}

class _PremiumCoursesSection extends StatelessWidget {
  const _PremiumCoursesSection({required this.coursesAsync, required this.s});
  final AsyncValue<List<Course>> coursesAsync;
  final S s;

  @override
  Widget build(BuildContext context) {
    return AsyncValueContent(
      value: coursesAsync,
      builder: (courses) {
        final premium = courses.where((c) => !c.isFree).toList();
        return BorderedSection(
          borderColor: AppColors.accentPurple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.accentPurple),
                  const SizedBox(width: 8),
                  Text(s.premiumCourses, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              ...premium.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CourseCard(course: c, onTap: () => context.push('/courses/${c.id}')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllServicesSection extends StatelessWidget {
  const _AllServicesSection({required this.servicesAsync, required this.s});
  final AsyncValue<List<FreelanceService>> servicesAsync;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.allServices),
        AsyncValueContent(
          value: servicesAsync,
          builder: (services) => Column(
            children: services
                .map((svc) => ServiceCard(service: svc, onTap: () => context.push('/services/${svc.id}')))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ProjectRequestTile extends StatelessWidget {
  const _ProjectRequestTile({
    required this.icon,
    required this.title,
    required this.budget,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String budget;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Text(budget, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
          const SizedBox(width: 6),
          Icon(Icons.check_circle_rounded, color: color, size: 18),
        ],
      ),
    );
  }
}
