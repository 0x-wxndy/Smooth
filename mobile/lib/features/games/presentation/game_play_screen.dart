import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.hint,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? hint;
}

abstract final class GameContent {
  static List<QuizQuestion> forGame(String gameId) {
    switch (gameId) {
      case 'game_color_harmony':
        return _colorHarmony;
      case 'game_layout_lab':
        return _layoutLab;
      case 'game_code_quiz':
      default:
        return _codeQuiz;
    }
  }

  static const _codeQuiz = [
    QuizQuestion(
      prompt: 'Which Flutter widget rebuilds when its value changes?',
      options: ['Container', 'StatefulWidget', 'SizedBox', 'Padding'],
      correctIndex: 1,
      hint: 'Think about widgets that hold mutable state.',
    ),
    QuizQuestion(
      prompt: 'What does `const` on a widget help with?',
      options: [
        'Makes it purple',
        'Compile-time reuse (fewer rebuilds)',
        'Adds animation',
        'Forces async',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Best place for shared app state in this prototype?',
      options: ['Global variables', 'Riverpod providers', 'print()', 'Hardcoded UI'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Which symbol starts a Dart string interpolation?',
      options: ['#{}', '\${}', '%s', '{{}}'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'A ListView that never ends should use…',
      options: ['Column only', 'ListView.builder', 'Stack forever', 'Spacer'],
      correctIndex: 1,
    ),
  ];

  static const _colorHarmony = [
    QuizQuestion(
      prompt: 'For a calm learning app, which primary feel fits best?',
      options: [
        'Neon pink + flash yellow',
        'Soft teal + deep navy',
        'Pure red + pure green',
        'All greys, no accent',
      ],
      correctIndex: 1,
      hint: 'Samooth Hub leans teal + navy.',
    ),
    QuizQuestion(
      prompt: 'Text on a dark navy hero should be…',
      options: ['Dark grey', 'White / soft white', 'Same navy', 'Bright yellow only'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Complementary accent to teal for CTAs?',
      options: ['Another teal', 'Warm coral or gold sparingly', 'Random rainbow', 'Black only'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Too many bright accents on one screen usually…',
      options: ['Improve focus', 'Create visual noise', 'Help SEO', 'Fix bugs'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Best use of pastel metric cards?',
      options: [
        'Background wallpaper only',
        'Soft stats without heavy borders',
        'Replace all photos',
        'Hide important CTAs',
      ],
      correctIndex: 1,
    ),
  ];

  static const _layoutLab = [
    QuizQuestion(
      prompt: 'Hero + two CTAs on mobile — best layout?',
      options: [
        'Tiny text top-right only',
        'Cover image + stacked / wrap buttons',
        '10 cards in the first viewport',
        'No spacing',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Long course list should use…',
      options: ['One giant Column', 'Scrollable ListView', 'Fixed height 40px', 'Hidden overflow'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Bottom navigation is for…',
      options: ['Ads only', 'Top-level destinations', 'Every setting', 'Modals'],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'Which creates clear visual hierarchy?',
      options: [
        'Same size for all text',
        'Bold title, quieter subtitle, strong CTA',
        'Everything underlined',
        'No whitespace',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      prompt: 'A “card” is most useful when…',
      options: [
        'Decorating empty space',
        'Grouping a tappable unit of content',
        'Replacing the hero image',
        'Showing 12 borders nested',
      ],
      correctIndex: 1,
    ),
  ];
}

class GamePlayScreen extends ConsumerStatefulWidget {
  const GamePlayScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  late final List<QuizQuestion> _questions;
  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _locked = false;
  bool _finished = false;
  String? _rewardMsg;
  int _earnedCoins = 0;
  int _earnedXp = 0;

  @override
  void initState() {
    super.initState();
    _questions = GameContent.forGame(widget.gameId);
  }

  Color get _accent {
    switch (widget.gameId) {
      case 'game_color_harmony':
        return AppColors.accentPink;
      case 'game_layout_lab':
        return AppColors.accentPurple;
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (widget.gameId) {
      case 'game_color_harmony':
        return Icons.palette_rounded;
      case 'game_layout_lab':
        return Icons.dashboard_customize_rounded;
      default:
        return Icons.code_rounded;
    }
  }

  Future<void> _pick(int i) async {
    if (_locked || _finished) return;
    setState(() {
      _selected = i;
      _locked = true;
      if (i == _questions[_index].correctIndex) _correct++;
    });
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _locked = false;
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final score = ((_correct / _questions.length) * 100).round();
    final userId = ref.read(authProvider).user?.id;
    String msg = 'Practice complete';
    var coins = 0;
    var xp = 0;
    if (userId != null) {
      final result = await ref.read(databaseProvider).completeGameSession(
            userId: userId,
            gameId: widget.gameId,
            scorePercent: score,
          );
      msg = result.message ?? msg;
      coins = result.coins;
      xp = result.xp;
      ref.invalidate(gamificationProvider);
      ref.invalidate(gamesProvider);
    }
    setState(() {
      _finished = true;
      _rewardMsg = msg;
      _earnedCoins = coins;
      _earnedXp = xp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesProvider);
    final title = gamesAsync.maybeWhen(
      data: (games) {
        for (final g in games) {
          if (g.id == widget.gameId) return g.title;
        }
        return 'Edu Game';
      },
      orElse: () => 'Edu Game',
    );

    if (_finished) {
      final score = ((_correct / _questions.length) * 100).round();
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_accent, _accent.withValues(alpha: 0.6)]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    score >= 60 ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 24),
                Text(
                  score >= 60 ? 'Nice work!' : 'Keep practicing',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_correct / ${_questions.length} correct · $score%',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_earnedCoins > 0 || _earnedXp > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.coin.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: AppColors.coin),
                        const SizedBox(width: 8),
                        Text(
                          '+$_earnedCoins coins',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.bolt_rounded, color: AppColors.accentPurple),
                        const SizedBox(width: 6),
                        Text(
                          '+$_earnedXp XP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                if (_rewardMsg != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _rewardMsg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: () => context.pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Learn', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _index = 0;
                      _correct = 0;
                      _selected = null;
                      _locked = false;
                      _finished = false;
                      _rewardMsg = null;
                      _earnedCoins = 0;
                      _earnedXp = 0;
                    });
                  },
                  child: const Text('Play again', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1}/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accent.withValues(alpha: 0.14),
                    AppColors.navy.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_icon, color: _accent, size: 28),
                  const SizedBox(height: 14),
                  Text(
                    q.prompt,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  if (q.hint != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      q.hint!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ).animate(key: ValueKey(_index)).fadeIn(duration: 280.ms).slideX(begin: 0.04),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: q.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final selected = _selected == i;
                  final correct = i == q.correctIndex;
                  Color border = AppColors.border;
                  Color bg = AppColors.surface;
                  if (_locked && selected && correct) {
                    border = AppColors.success;
                    bg = AppColors.pastelMint;
                  } else if (_locked && selected && !correct) {
                    border = AppColors.error;
                    bg = const Color(0xFFFEE2E2);
                  } else if (_locked && correct) {
                    border = AppColors.success;
                    bg = AppColors.pastelMint;
                  }

                  return Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _pick(i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(fontWeight: FontWeight.w800, color: _accent, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                q.options[i],
                                style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
