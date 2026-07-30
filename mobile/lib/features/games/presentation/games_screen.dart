import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';

class GamesTab extends ConsumerWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final gamesAsync = ref.watch(gamesProvider);
    final walletAsync = ref.watch(gamificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
     
      body: AsyncValueContent(
        value: gamesAsync,
        builder: (games) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              s.eduGamesSub,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ...games.map((g) => _GameCard(game: g)),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final EducationalGame game;

  Color get _color {
    switch (game.id) {
      case 'game_color_harmony':
        return AppColors.accentPink;
      case 'game_layout_lab':
        return AppColors.accentPurple;
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (game.id) {
      case 'game_color_harmony':
        return Icons.palette_rounded;
      case 'game_layout_lab':
        return Icons.dashboard_customize_rounded;
      default:
        return Icons.code_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/games/${game.id}'),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_color, _color.withValues(alpha: 0.65)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.category,
                        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${game.coinReward} · +${game.xpReward} XP',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: _color, size: 32),
        ],
      ),
    );
  }
}
