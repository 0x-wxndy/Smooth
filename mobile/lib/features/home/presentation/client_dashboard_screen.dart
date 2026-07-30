import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../profile/presentation/profile_portfolio_section.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/hub_hero.dart';
import '../../../shared/widgets/back_to_menu_bar.dart';
import '../../../shared/widgets/smooth_components.dart';

class ClientDashboardTab extends ConsumerWidget {
  const ClientDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final user = ref.watch(authProvider).user;
    final servicesAsync = ref.watch(servicesProvider);
    final jobsAsync = ref.watch(jobsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: BackToMenuBar()),
          SliverToBoxAdapter(
            child: HubHeroShell(
              brandTitle: s.clientHub,
              greeting: 'Hi, ${user?.displayName ?? 'Client'}',
              heroTitle: s.clientHeroTitle,
              heroSubtitle: s.clientHeroSubtitle,
              coverUrl: AppAssets.heroWorkspace,
              coverHeight: 330,
              primaryCta: HubCta(
                label: s.browseFreelancers,
                icon: Icons.person_search,
                onPressed: () => context.go('/market'),
              ),
              secondaryCta: HubCta(
                label: s.hubFacilities,
                icon: Icons.apartment_outlined,
                onPressed: () => context.push('/hub'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubContentSheet(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.clientMarketTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            s.clientMarketSub,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                             Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  final userId = user?.id;
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
                                  onPressed: () => context.go('/market'),
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentGreen),
                                  child: Text(s.hireTalent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SectionHeader(title: s.topServices),
                    AsyncValueContent(
                      value: servicesAsync,
                      builder: (services) => Column(
                        children: services
                            .take(4)
                            .map(
                              (svc) => ServiceCard(
                                service: svc,
                                onTap: () => context.push('/services/${svc.id}'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SectionHeader(
                      title: s.jobs,
                      actionLabel: s.seeAll,
                      onAction: () => context.go('/jobs'),
                    ),
                    AsyncValueContent(
                      value: jobsAsync,
                      builder: (jobs) => Column(
                        children: jobs
                            .take(2)
                            .map((j) => JobCard(job: j, onTap: () => context.go('/jobs')))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
