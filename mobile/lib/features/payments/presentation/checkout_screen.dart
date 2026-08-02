import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../payment_models.dart';
import 'payment_fulfillment.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.args});

  final PaymentCheckoutArgs args;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentGateway? _selected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final args = widget.args;
    final walletAsync = ref.watch(gamificationProvider);

    final methods = <PaymentGateway>[
      PaymentGateway.edahabia,
      PaymentGateway.cib,
      PaymentGateway.card,
      if (args.canPayWithCoins) PaymentGateway.coins,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(s.checkout)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.gradientNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.orderSummary,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  args.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                if (args.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(args.subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(s.total, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                    const Spacer(),
                    Text(
                      Money.format(args.amountCentimes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(s.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            s.mockPaymentNote,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          ...methods.map((g) {
            final selected = _selected == g;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: selected ? g.brandColor.withValues(alpha: 0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => setState(() => _selected = g),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? g.brandColor : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: g.brandColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(g.icon, color: g.brandColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text(
                                g == PaymentGateway.coins
                                    ? '${g.subtitle} (${args.coinCost})'
                                    : g.subtitle,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (g == PaymentGateway.coins)
                          walletAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (w) => CoinBadge(amount: w.coins),
                          )
                        else
                          Icon(
                            selected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selected ? g.brandColor : AppColors.textMuted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SmoothButton(
            label: _selected == null ? s.selectPaymentMethod : s.continueToPay,
            onPressed: _selected == null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.selectPaymentMethod)),
                    );
                  }
                : () => _continue(context),
          ),
        ),
      ),
    );
  }

  Future<void> _continue(BuildContext context) async {
    final gateway = _selected!;
    final args = widget.args;

    if (gateway == PaymentGateway.coins) {
      await _payWithCoins(context);
      return;
    }

    final path = switch (gateway) {
      PaymentGateway.edahabia => '/pay/edahabia',
      PaymentGateway.cib => '/pay/cib',
      PaymentGateway.card => '/pay/card',
      PaymentGateway.coins => '/pay/edahabia',
    };

    if (!context.mounted) return;
    context.push(path, extra: args);
  }

  Future<void> _payWithCoins(BuildContext context) async {
    final s = S.of(context);
    final userId = ref.read(authProvider).user?.id;
    final cost = widget.args.coinCost ?? 0;
    if (userId == null) return;

    final ok = await ref.read(databaseProvider).spendCoins(userId, cost);
    if (!ok) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.notEnoughCoins), backgroundColor: AppColors.error),
      );
      return;
    }

    await PaymentFulfillment.apply(context, widget.args, PaymentGateway.coins);
    ref.invalidate(gamificationProvider);

    if (!context.mounted) return;
    context.pushReplacement(
      '/pay/result',
      extra: PaymentResultArgs(
        success: true,
        title: widget.args.title,
        amountCentimes: 0,
        gateway: PaymentGateway.coins,
        purpose: widget.args.purpose,
        itemId: widget.args.itemId,
        aiTokens: widget.args.aiTokens,
        transactionRef: 'COIN-${DateTime.now().millisecondsSinceEpoch}',
        message: s.paymentSuccessCoins,
      ),
    );
  }
}
