import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../shared/models/dm_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../payments/payment_models.dart';

class DmThreadScreen extends ConsumerStatefulWidget {
  const DmThreadScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<DmThreadScreen> createState() => _DmThreadScreenState();
}

class _DmThreadScreenState extends ConsumerState<DmThreadScreen> {
  final _textCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    final me = ref.read(authProvider).user;
    if (me == null) return;

    setState(() => _sending = true);
    await ref.read(databaseProvider).sendDmText(
          conversationId: widget.conversationId,
          senderId: me.id,
          body: text,
        );
    ref.invalidate(dmMessagesProvider(widget.conversationId));
    ref.invalidate(conversationsProvider);
    if (!mounted) return;
    setState(() {
      _textCtrl.clear();
      _sending = false;
    });
  }

  Future<void> _showSendOfferSheet(DmConversation conv) async {
    final s = S.of(context);
    final me = ref.read(authProvider).user;
    if (me == null || me.id != conv.providerId) return;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.sendOffer, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: s.offerTitle, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: s.offerDescription, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: s.offerAmount,
                      suffixText: 'DZD',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: saving || titleCtrl.text.trim().isEmpty || amount <= 0
                        ? null
                        : () async {
                            setState(() => saving = true);
                            await ref.read(databaseProvider).createEscrowOffer(
                                  conversationId: widget.conversationId,
                                  providerId: me.id,
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  amountCents: amount * 100,
                                );
                            ref.invalidate(dmMessagesProvider(widget.conversationId));
                            ref.invalidate(conversationsProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(s.sendOffer, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    amountCtrl.dispose();
  }

  void _payEscrow(EscrowDeal deal) {
    final s = S.of(context);
    context.push(
      '/checkout',
      extra: PaymentCheckoutArgs(
        title: deal.title,
        subtitle: s.escrowPaySubtitle,
        amountCentimes: deal.amountCents,
        purpose: PaymentPurpose.escrow,
        itemId: deal.id,
      ),
    );
  }

  Future<void> _markDelivered(EscrowDeal deal) async {
    final me = ref.read(authProvider).user;
    if (me == null) return;
    await ref.read(databaseProvider).markEscrowDelivered(deal.id, me.id);
    ref.invalidate(escrowDealProvider(deal.id));
    ref.invalidate(dmMessagesProvider(widget.conversationId));
    ref.invalidate(conversationsProvider);
  }

  Future<void> _approveRelease(EscrowDeal deal) async {
    final s = S.of(context);
    final me = ref.read(authProvider).user;
    if (me == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.approveRelease),
        content: Text(s.approveReleaseConfirm(deal.amountLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.approveRelease)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(databaseProvider).approveEscrowDeal(deal.id, me.id);
    ref.invalidate(escrowDealProvider(deal.id));
    ref.invalidate(dmMessagesProvider(widget.conversationId));
    ref.invalidate(conversationsProvider);
    ref.invalidate(gamificationProvider);
    ref.invalidate(paymentLogsProvider);
    ref.invalidate(adminActivityLogsProvider);
    ref.invalidate(adminStatsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.escrowReleased), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final me = ref.watch(authProvider).user;
    final convAsync = ref.watch(dmConversationProvider(widget.conversationId));
    final msgsAsync = ref.watch(dmMessagesProvider(widget.conversationId));

    return AsyncValueContent(
      value: convAsync,
      builder: (conv) {
        if (conv == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(s.userNotFound)),
          );
        }

        final peerName = me == null ? 'User' : conv.peerNameFor(me.id);
        final isProvider = me?.id == conv.providerId;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(peerName, style: const TextStyle(fontSize: 16)),
                Text(
                  s.directMessage,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              if (isProvider)
                IconButton(
                  icon: const Icon(Icons.request_quote_outlined),
                  tooltip: s.sendOffer,
                  onPressed: () => _showSendOfferSheet(conv),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ColoredBox(
                  color: const Color(0xFFF0F2F5),
                  child: AsyncValueContent(
                    value: msgsAsync,
                    builder: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(s.startConversation, style: const TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          if (msg.isOffer && msg.dealId != null) {
                            return _EscrowOfferCard(
                              dealId: msg.dealId!,
                              me: me,
                              onPay: _payEscrow,
                              onMarkDelivered: _markDelivered,
                              onApprove: _approveRelease,
                            );
                          }
                          return _DmBubble(message: msg, meId: me?.id);
                        },
                      );
                    },
                  ),
                ),
              ),
              Material(
                elevation: 8,
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textCtrl,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendText(),
                            decoration: InputDecoration(
                              hintText: s.typeYourMessage,
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filled(
                          onPressed: _sending ? null : _sendText,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
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

class _DmBubble extends StatelessWidget {
  const _DmBubble({required this.message, required this.meId});

  final DmMessage message;
  final String? meId;

  @override
  Widget build(BuildContext context) {
    final incoming = message.isSystem || message.senderId != meId;
    final sender = message.isSystem ? 'Samooth' : (message.senderName ?? 'User');

    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: message.isSystem
              ? AppColors.pastelMint
              : (incoming ? Colors.white : AppColors.primarySoft),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(incoming ? 4 : 16),
            bottomRight: Radius.circular(incoming ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isSystem)
              Text(
                sender,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: incoming ? AppColors.primary : AppColors.navy,
                ),
              ),
            if (!message.isSystem) const SizedBox(height: 4),
            Text(message.body, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _EscrowOfferCard extends ConsumerWidget {
  const _EscrowOfferCard({
    required this.dealId,
    required this.me,
    required this.onPay,
    required this.onMarkDelivered,
    required this.onApprove,
  });

  final String dealId;
  final AppUser? me;
  final void Function(EscrowDeal deal) onPay;
  final Future<void> Function(EscrowDeal deal) onMarkDelivered;
  final Future<void> Function(EscrowDeal deal) onApprove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final dealAsync = ref.watch(escrowDealProvider(dealId));

    return dealAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (deal) {
        if (deal == null) return const SizedBox.shrink();

        final isClient = me?.id == deal.clientId;
        final isProvider = me?.id == deal.providerId;
        final statusLabel = switch (deal.status) {
          EscrowStatus.pendingPayment => s.escrowPending,
          EscrowStatus.funded => s.escrowFunded,
          EscrowStatus.delivered => s.escrowDelivered,
          EscrowStatus.completed => s.escrowCompleted,
          EscrowStatus.cancelled => s.escrowCancelled,
        };

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.handshake_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(s.escrowOffer, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pastelSky,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (deal.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(deal.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(s.amount, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const Spacer(),
                  Text(deal.amountLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                s.escrowFeeNote(Money.format(deal.computedPlatformFee)),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              if (deal.status == EscrowStatus.completed) ...[
                const SizedBox(height: 8),
                Text(
                  s.escrowPayoutSummary(
                    Money.format(deal.computedProviderPayout),
                    Money.format(deal.computedPlatformFee),
                  ),
                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              if (isClient && deal.status == EscrowStatus.pendingPayment)
                FilledButton.icon(
                  onPressed: () => onPay(deal),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(s.payEscrow),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              if (isProvider && deal.status == EscrowStatus.funded)
                FilledButton.icon(
                  onPressed: () => onMarkDelivered(deal),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(s.markDelivered),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              if (isClient && deal.status == EscrowStatus.delivered)
                FilledButton.icon(
                  onPressed: () => onApprove(deal),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(s.approveRelease),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
