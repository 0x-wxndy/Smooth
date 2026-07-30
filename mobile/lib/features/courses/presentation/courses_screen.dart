import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../features/payments/payment_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';
import '../../../shared/widgets/smooth_components.dart';
import 'learn_mentors_section.dart';

class LearnTab extends ConsumerStatefulWidget {
  const LearnTab({super.key});

  @override
  ConsumerState<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends ConsumerState<LearnTab> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    final walletAsync = ref.watch(gamificationProvider);
    final quotaAsync = ref.watch(aiQuotaProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final filters = [s.filterAll, s.free, s.filterPremium];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const AiAssistantFab(),

      body: AsyncValueContent(
        value: coursesAsync,
        builder: (courses) {
          final filtered = switch (_filterIndex) {
            1 => courses.where((c) => c.isFree).toList(),
            2 => courses.where((c) => !c.isFree).toList(),
            _ => courses,
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // Wallet strip
              walletAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (w) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientNavy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _WalletStat(
                          icon: Icons.monetization_on_rounded,
                          iconColor: AppColors.coin,
                          label: s.coins,
                          value: '${w.coins}',
                        ),
                      ),
                      Expanded(
                        child: _WalletStat(
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFC4B5FD),
                          label: s.xp,
                          value: '${w.xp}',
                        ),
                      ),
                      Expanded(
                        child: _WalletStat(
                          icon: Icons.smart_toy_rounded,
                          iconColor: AppColors.accent,
                          label: s.aiTokens,
                          value: '${w.aiTokenBank}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // AI tokens card
              quotaAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (q) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.accentPurple),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.aiAssistant, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.freeToday}: ${q.freeRemaining}/${q.freeLimit} · ${s.bonusTokens}: ${q.bank}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.aiUnlockHint,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/ai'),
                              child: Text(s.openAi),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _showUnlockSheet(context),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.accentPurple),
                              child: Text(s.unlockTokens),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Games
              SectionHeader(
                title: s.eduGames,
                actionLabel: s.seeAll,
                onAction: () => context.push('/games'),
              ),
              gamesAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
                data: (games) => SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: games.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final g = games[i];
                      final color = switch (g.id) {
                        'game_color_harmony' => AppColors.accentPink,
                        'game_layout_lab' => AppColors.accentPurple,
                        _ => AppColors.primary,
                      };
                      final icon = switch (g.id) {
                        'game_color_harmony' => Icons.palette_rounded,
                        'game_layout_lab' => Icons.dashboard_customize_rounded,
                        _ => Icons.code_rounded,
                      };
                      return InkWell(
                        onTap: () => context.push('/games/${g.id}'),
                        borderRadius: BorderRadius.circular(18),
                        child: Ink(
                          width: 150,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color, color.withValues(alpha: 0.75)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: Colors.white, size: 28),
                              const Spacer(),
                              Text(
                                g.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+${g.coinReward} ${s.coins.toLowerCase()}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const LearnMentorsSection(),

              SectionHeader(title: s.courses),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (_, i) => SmoothChipFilter(
                    label: filters[i],
                    selected: _filterIndex == i,
                    onTap: () => setState(() => _filterIndex = i),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.lessonRewardHint,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...filtered.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CourseCard(
                    course: c,
                    onTap: () => context.push('/courses/${c.id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showUnlockSheet(BuildContext context) async {
    final s = S.of(context);
    final wallet = await ref.read(gamificationProvider.future);

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(s.unlockTokens, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                '${s.coins}: ${wallet.coins}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _PackTile(
                title: s.aiPackSmall,
                subtitle:
                    '${AppConfig.aiPackSmallCoins} ${s.coins.toLowerCase()}  ·  ${Money.format(AppConfig.aiPackSmallDzd)}',
                tokens: AppConfig.aiPackSmallTokens,
                color: AppColors.primary,
                onTap: () => _buyPack(
                  ctx,
                  coins: AppConfig.aiPackSmallCoins,
                  tokens: AppConfig.aiPackSmallTokens,
                  dzdCentimes: AppConfig.aiPackSmallDzd,
                  title: s.aiPackSmall,
                ),
              ),
              const SizedBox(height: 10),
              _PackTile(
                title: s.aiPackLarge,
                subtitle:
                    '${AppConfig.aiPackLargeCoins} ${s.coins.toLowerCase()}  ·  ${Money.format(AppConfig.aiPackLargeDzd)} · ${s.bestValue}',
                tokens: AppConfig.aiPackLargeTokens,
                color: AppColors.accentPurple,
                featured: true,
                onTap: () => _buyPack(
                  ctx,
                  coins: AppConfig.aiPackLargeCoins,
                  tokens: AppConfig.aiPackLargeTokens,
                  dzdCentimes: AppConfig.aiPackLargeDzd,
                  title: s.aiPackLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.payWithEdahabia,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _buyPack(
    BuildContext sheetContext, {
    required int coins,
    required int tokens,
    required int dzdCentimes,
    required String title,
  }) async {
    Navigator.pop(sheetContext);
    if (!mounted) return;
    context.push(
      '/checkout',
      extra: PaymentCheckoutArgs(
        title: title,
        subtitle: '+$tokens AI tokens',
        amountCentimes: dzdCentimes,
        purpose: PaymentPurpose.aiTokens,
        aiTokens: tokens,
        coinCost: coins,
      ),
    );
  }
}
class _WalletStat extends StatelessWidget {
  const _WalletStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
      ],
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.title,
    required this.subtitle,
    required this.tokens,
    required this.color,
    required this.onTap,
    this.featured = false,
  });

  final String title;
  final String subtitle;
  final int tokens;
  final Color color;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: featured ? color.withValues(alpha: 0.1) : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.token_rounded, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('+$tokens', style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
