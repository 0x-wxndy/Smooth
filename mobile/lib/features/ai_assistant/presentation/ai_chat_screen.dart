import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../features/payments/payment_models.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/smooth_components.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _messages = <ChatMessage>[
    ChatMessage(
      content: 'Hi! I can help you pick a learning path, explain concepts, or suggest what to study next.',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final consumed = await ref.read(databaseProvider).consumeAiToken(userId);
    if (!consumed) {
      if (!mounted) return;
      _showOutOfTokens();
      return;
    }

    ref.invalidate(aiQuotaProvider);
    ref.invalidate(aiUsageProvider);
    ref.invalidate(gamificationProvider);

    setState(() {
      _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(
          content: _mockReply(text),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _showOutOfTokens() {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.token_rounded, size: 40, color: AppColors.accentPurple),
            const SizedBox(height: 12),
            Text(s.unlockTokens, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              s.aiUnlockHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openCheckout(
                  title: s.aiPackSmall,
                  tokens: AppConfig.aiPackSmallTokens,
                  coins: AppConfig.aiPackSmallCoins,
                  dzd: AppConfig.aiPackSmallDzd,
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('${s.aiPackSmall}\n${Money.format(AppConfig.aiPackSmallDzd)}', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openCheckout(
                  title: s.aiPackLarge,
                  tokens: AppConfig.aiPackLargeTokens,
                  coins: AppConfig.aiPackLargeCoins,
                  dzd: AppConfig.aiPackLargeDzd,
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentPurple),
              child: Text('${s.aiPackLarge}\n${Money.format(AppConfig.aiPackLargeDzd)}', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  void _openCheckout({
    required String title,
    required int tokens,
    required int coins,
    required int dzd,
  }) {
    context.push(
      '/checkout',
      extra: PaymentCheckoutArgs(
        title: title,
        subtitle: '+$tokens AI tokens',
        amountCentimes: dzd,
        purpose: PaymentPurpose.aiTokens,
        aiTokens: tokens,
        coinCost: coins,
      ),
    );
  }

  String _mockReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('mobile') || lower.contains('flutter')) {
      return 'Start with Dart fundamentals, then build a small Flutter app with navigation and state management. Aim for 30 minutes daily.';
    }
    if (lower.contains('design')) {
      return 'Focus on typography and layout first. Redesign one app screen per day in Figma to build muscle memory.';
    }
    if (lower.contains('coin') || lower.contains('game')) {
      return 'Play Edu Games from Learn (60%+ once/day) or complete lessons for coins. Spend coins to unlock AI token packs.';
    }
    return 'Based on your goals, I recommend picking one skill area and completing a beginner course this week. Want a structured 7-day plan?';
  }

  @override
  Widget build(BuildContext context) {
    final quotaAsync = ref.watch(aiQuotaProvider);
    final walletAsync = ref.watch(gamificationProvider);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.aiAssistant),
        actions: [
          walletAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (w) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: CoinBadge(amount: w.coins)),
            ),
          ),
          quotaAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (q) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: GestureDetector(
                  onTap: _showOutOfTokens,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${q.totalRemaining} ${s.aiTokens.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          quotaAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (q) => Material(
              color: AppColors.pastelLavender,
              child: InkWell(
                onTap: _showOutOfTokens,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.accentPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${s.freeToday} ${q.freeRemaining}/${q.freeLimit} · ${s.bonusTokens} ${q.bank}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        s.unlockTokens,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(message: _messages[i]),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _QuickChip('Study plan', () => _send('Create a study plan for me')),
                _QuickChip('Quiz me', () => _send('Generate a quick quiz')),
                _QuickChip('Earn coins?', () => _send('How do I earn coins and AI tokens?')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: () => _send(), icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, height: 1.4),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}
