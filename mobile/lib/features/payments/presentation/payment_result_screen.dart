import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../payment_models.dart';

class PaymentResultScreen extends ConsumerWidget {
  const PaymentResultScreen({super.key, required this.args});

  final PaymentResultArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final ok = args.success;

    return Scaffold(
      backgroundColor: ok ? AppColors.navy : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: ok ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ok ? Icons.check_rounded : Icons.close_rounded,
                  size: 52,
                  color: ok ? AppColors.success : AppColors.error,
                ),
              ).animate().scale(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                ok ? s.paymentSuccess : s.paymentFailed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ok ? Colors.white : AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                args.message ?? args.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ok ? Colors.white70 : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ok ? Colors.white.withValues(alpha: 0.08) : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ok ? Colors.white24 : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    _row(s.order, args.title, ok),
                    const SizedBox(height: 10),
                    _row(s.gateway, args.gateway.label, ok),
                    const SizedBox(height: 10),
                    _row(
                      s.amount,
                      args.gateway == PaymentGateway.coins
                          ? s.paidWithCoins
                          : Money.format(args.amountCentimes),
                      ok,
                    ),
                    if (args.transactionRef != null) ...[
                      const SizedBox(height: 10),
                      _row(s.reference, args.transactionRef!, ok),
                    ],
                    if (ok && args.aiTokens != null) ...[
                      const SizedBox(height: 10),
                      _row(s.aiTokens, '+${args.aiTokens}', ok),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SmoothButton(
                label: s.backHome,
                onPressed: () => context.go('/home'),
              ),
              if (ok && args.purpose == PaymentPurpose.course && args.itemId != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/courses/${args.itemId}'),
                  child: Text(
                    s.openCourse,
                    style: TextStyle(color: ok ? Colors.white70 : AppColors.primary),
                  ),
                ),
              ],
              if (ok && args.purpose == PaymentPurpose.aiTokens) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/ai'),
                  child: Text(
                    s.openAi,
                    style: TextStyle(color: ok ? Colors.white70 : AppColors.primary),
                  ),
                ),
              ],
              if (ok && args.purpose == PaymentPurpose.subscription) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/learn'),
                  child: Text(
                    s.exploreMasterclasses,
                    style: TextStyle(color: ok ? Colors.white70 : AppColors.primary),
                  ),
                ),
              ],
              if (ok && (args.purpose == PaymentPurpose.hubRoom || args.purpose == PaymentPurpose.hubPrint)) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/hub'),
                  child: Text(
                    s.bookInHub,
                    style: TextStyle(color: ok ? Colors.white70 : AppColors.primary),
                  ),
                ),
              ],
              if (ok && args.purpose == PaymentPurpose.escrow && args.itemId != null) ...[
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, _) {
                    final dealAsync = ref.watch(escrowDealProvider(args.itemId!));
                    return dealAsync.when(
                      data: (deal) {
                        if (deal == null) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () => context.go('/messages/dm/${deal.conversationId}'),
                          child: Text(
                            s.backToConversation,
                            style: TextStyle(color: ok ? Colors.white70 : AppColors.primary),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v, bool dark) {
    return Row(
      children: [
        Text(k, style: TextStyle(color: dark ? Colors.white54 : AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: dark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
