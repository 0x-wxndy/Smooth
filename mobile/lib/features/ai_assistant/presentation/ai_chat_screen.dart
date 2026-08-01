import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../features/payments/payment_models.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/models/user_model.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _welcomeReady = false;
  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureWelcome() {
    if (_welcomeReady) return;
    final s = S.of(context);
    final user = ref.read(authProvider).user;
    final name = user?.displayName;
    final isCreator = user?.role == UserRole.teacher || user?.role == UserRole.client;
    final welcome = isCreator
        ? (name != null ? s.aiWelcomeCreatorName(name.split(' ').first) : s.aiWelcomeCreator)
        : (name != null ? s.aiWelcome(name.split(' ').first) : s.aiWelcomeGuest);
    _messages.add(
      ChatMessage(
        content: welcome,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _welcomeReady = true;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty || _isThinking) return;

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
      _isThinking = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(
          content: _mockReply(text),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isThinking = false;
    });
    _scrollToBottom();
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

  bool _isCreatorRole() {
  final role = ref.read(authProvider).user?.role;
  return role == UserRole.teacher || role == UserRole.client;
}

  String _mockReply(String input) {
    final s = S.of(context);
    final lower = input.toLowerCase();

    if (_isCreatorRole()) {
      if (lower.contains('course') || lower.contains('idée') || lower.contains('idea') || lower.contains('فكرة')) {
        return s.aiReplyCourseIdea;
      }
      if (lower.contains('price') || lower.contains('pricing') || lower.contains('tarif') || lower.contains('سعّر') || lower.contains('prix')) {
        return s.aiReplyPricing;
      }
      if (lower.contains('marketing') || lower.contains('promo') || lower.contains('post') || lower.contains('تسويقي')) {
        return s.aiReplyMarketing;
      }
      if (lower.contains('portfolio') || lower.contains('معرض')) {
        return s.aiReplyPortfolioTip;
      }
      if (lower.contains('career') || lower.contains('carrière') || lower.contains('job') || lower.contains('recruit')) {
        return s.aiReplyCareer;
      }
      if (lower.contains('coin') || lower.contains('game') || lower.contains('pièce') || lower.contains('jeton') || lower.contains('token')) {
        return s.aiReplyCoins;
      }
      return s.aiReplyCreatorDefault;
    }

    if (lower.contains('plan') || lower.contains('étude') || lower.contains('study')) {
      return s.aiReplyStudyPlan;
    }
    if (lower.contains('quiz') || lower.contains('question')) {
      return s.aiReplyQuiz;
    }
    if (lower.contains('mobile') || lower.contains('flutter') || lower.contains('dart')) {
      return s.aiReplyFlutter;
    }
    if (lower.contains('design') || lower.contains('figma') || lower.contains('ui')) {
      return s.aiReplyDesign;
    }
    if (lower.contains('coin') || lower.contains('game') || lower.contains('pièce') || lower.contains('jeton') || lower.contains('token')) {
      return s.aiReplyCoins;
    }
    if (lower.contains('career') || lower.contains('carrière') || lower.contains('job') || lower.contains('portfolio') || lower.contains('recruit')) {
      return s.aiReplyCareer;
    }
    return s.aiReplyDefault;
  }

  @override
  Widget build(BuildContext context) {
    _ensureWelcome();
    final quotaAsync = ref.watch(aiQuotaProvider);
    final walletAsync = ref.watch(gamificationProvider);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.aiAssistant),
            Text(
              s.aiAssistantName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
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
                      const Icon(Icons.auto_awesome, size: 16, color: AppColors.accentPurple),
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
            child: ColoredBox(
              color: const Color(0xFFF0F2F5),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return _TypingBubble(label: s.aiTyping);
                  }
                  return _Bubble(message: _messages[i], assistantName: s.aiAssistantName);
                },
              ),
            ),
          ),
          if (!_isThinking && _messages.length <= 2)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: _isCreatorRole()
                    ? [
                        _QuickChip(s.aiChipCourseIdea, () => _send(s.aiPromptCourseIdea)),
                        _QuickChip(s.aiChipPricing, () => _send(s.aiPromptPricing)),
                        _QuickChip(s.aiChipMarketing, () => _send(s.aiPromptMarketing)),
                        _QuickChip(s.aiChipPortfolio, () => _send(s.aiPromptPortfolio)),
                        _QuickChip(s.aiChipCareer, () => _send(s.aiChipCareer)),
                      ]
                    : [
                        _QuickChip(s.aiChipStudyPlan, () => _send(s.aiPromptStudyPlan)),
                        _QuickChip(s.aiChipQuiz, () => _send(s.aiPromptQuiz)),
                        _QuickChip(s.aiChipCoins, () => _send(s.aiPromptCoins)),
                        _QuickChip(s.aiChipFlutter, () => _send(s.aiChipFlutter)),
                        _QuickChip(s.aiChipCareer, () => _send(s.aiChipCareer)),
                      ],
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
                        controller: _controller,
                        enabled: !_isThinking,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: s.aiInputHint,
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
                      onPressed: _isThinking ? null : () => _send(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isThinking
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
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.assistantName});

  final ChatMessage message;
  final String assistantName;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time = DateFormat.Hm().format(message.timestamp.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.pastelLavender,
              child: Icon(Icons.auto_awesome, size: 14, color: AppColors.accentPurple),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: isUser
                    ? null
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        assistantName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentPurple),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, height: 1.45),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 10, color: isUser ? Colors.white70 : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.label});

  final String label;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.pastelLavender,
            child: Icon(Icons.auto_awesome, size: 14, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _dots,
                  builder: (_, __) {
                    return Row(
                      children: List.generate(3, (i) {
                        final active = (_dots.value * 3).floor() == i;
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accentPurple : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.accentPurple.withValues(alpha: 0.35)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentPurple),
        onPressed: onTap,
      ),
    );
  }
}
