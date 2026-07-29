import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/subscription_plan.dart';
import '../../../shared/providers/subscription_provider.dart';

class SubscriptionSection extends ConsumerWidget {
  const SubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final selected = ref.watch(subscriptionProvider);

    return Padding(
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
                Expanded(
                  child: Text(s.vipBenefits, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.subscriptionTypesHint,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 14),
            Text(s.subscriptionTypes, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PlanCard(
                      plan: SubscriptionPlan.free,
                      title: s.planFree,
                      priceLabel: s.planFreePrice,
                      selected: selected == SubscriptionPlan.free,
                      accent: AppColors.textSecondary,
                      onTap: () => _selectPlan(context, ref, SubscriptionPlan.free),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanCard(
                      plan: SubscriptionPlan.premium,
                      title: s.planPremium,
                      priceLabel: s.planPremiumPrice,
                      badge: s.planPopular,
                      selected: selected == SubscriptionPlan.premium,
                      accent: AppColors.accentPurple,
                      onTap: () => _selectPlan(context, ref, SubscriptionPlan.premium),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanCard(
                      plan: SubscriptionPlan.vip,
                      title: s.planVip,
                      priceLabel: s.planVipPrice,
                      badge: s.planBestValue,
                      selected: selected == SubscriptionPlan.vip,
                      accent: const Color(0xFFD97706),
                      onTap: () => _selectPlan(context, ref, SubscriptionPlan.vip),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanComparisonTable(s: s, selected: selected),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _confirmSelection(context, ref, selected, s),
                style: FilledButton.styleFrom(
                  backgroundColor: selected.isPaid ? AppColors.accentPurple : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  selected.isPaid ? s.activatePlan(selected.planLabel(s)) : s.exploreMasterclasses,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, WidgetRef ref, SubscriptionPlan plan) async {
    await ref.read(subscriptionProvider.notifier).selectPlan(plan);
  }

  Future<void> _confirmSelection(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
    S s,
  ) async {
    if (!plan.isPaid) {
      if (context.mounted) context.go('/learn');
      return;
    }

    await ref.read(subscriptionProvider.notifier).selectPlan(plan);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.planActivated(plan.planLabel(s))),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension _PlanLabel on SubscriptionPlan {
  String planLabel(S s) => switch (this) {
        SubscriptionPlan.free => s.planFree,
        SubscriptionPlan.premium => s.planPremium,
        SubscriptionPlan.vip => s.planVip,
      };
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.title,
    required this.priceLabel,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final SubscriptionPlan plan;
  final String title;
  final String priceLabel;
  final String? badge;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accent.withValues(alpha: 0.1) : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: accent),
                  ),
                ),
                const SizedBox(height: 6),
              ] else
                const SizedBox(height: 18),
              if (selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 18)
              else
                Icon(Icons.circle_outlined, color: AppColors.border, size: 18),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: selected ? accent : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                priceLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanComparisonTable extends StatelessWidget {
  const _PlanComparisonTable({required this.s, required this.selected});

  final S s;
  final SubscriptionPlan selected;

  @override
  Widget build(BuildContext context) {
    final plans = SubscriptionPlan.values;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 5, child: SizedBox()),
            ...plans.map(
              (plan) => Expanded(
                flex: 2,
                child: Text(
                  plan.planLabel(s),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: plan == selected ? _accentFor(plan) : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _FeatureRow(
          label: s.masterclassAccess,
          values: const [
            _CellText('3'),
            _CellText('∞'),
            _CellText('∞'),
          ],
          highlight: selected,
        ),
        _FeatureRow(
          label: s.sourceFiles,
          values: const [_CellDash(), _CellCheck(), _CellCheck()],
          highlight: selected,
        ),
        _FeatureRow(
          label: s.priorityReview,
          values: const [_CellDash(), _CellCheck(), _CellCheck()],
          highlight: selected,
        ),
        _FeatureRow(
          label: s.webinars,
          values: const [_CellDash(), _CellCheck(), _CellCheck()],
          highlight: selected,
        ),
        _FeatureRow(
          label: s.planVipPerk,
          values: const [_CellDash(), _CellDash(), _CellCheck()],
          highlight: selected,
        ),
      ],
    );
  }

  static Color _accentFor(SubscriptionPlan plan) => switch (plan) {
        SubscriptionPlan.free => AppColors.textSecondary,
        SubscriptionPlan.premium => AppColors.accentPurple,
        SubscriptionPlan.vip => const Color(0xFFD97706),
      };
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.values,
    required this.highlight,
  });

  final String label;
  final List<Widget> values;
  final SubscriptionPlan highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.25),
            ),
          ),
          ...List.generate(values.length, (i) {
            final plan = SubscriptionPlan.values[i];
            final isSelected = plan == highlight;
            return Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: isSelected
                    ? BoxDecoration(
                        color: _PlanComparisonTable._accentFor(plan).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: values[i],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CellCheck extends StatelessWidget {
  const _CellCheck();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.check_circle, color: AppColors.accentPurple, size: 16);
  }
}

class _CellDash extends StatelessWidget {
  const _CellDash();

  @override
  Widget build(BuildContext context) {
    return const Text('—', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted));
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accentPurple),
    );
  }
}
