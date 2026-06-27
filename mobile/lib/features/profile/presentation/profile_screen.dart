import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/smooth_button.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncValueContent(
        value: statsAsync,
        builder: (stats) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (user?.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      if (user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            roleDisplayName(user.role),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      LevelBadge(level: stats.level),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SmoothCard(
              child: Column(
                children: [
                  _StatRow(label: 'Coins', value: '${stats.coins}', icon: Icons.monetization_on, color: AppColors.coin),
                  const Divider(height: 24),
                  _StatRow(label: 'XP', value: '${stats.xp}', icon: Icons.bolt, color: AppColors.primary),
                  const Divider(height: 24),
                  _StatRow(
                    label: 'Streak',
                    value: '${stats.currentStreak} days',
                    icon: Icons.local_fire_department,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Achievements'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _Badge(icon: Icons.school, label: 'First Course'),
                _Badge(icon: Icons.quiz, label: 'Quiz Master'),
                _Badge(icon: Icons.videogame_asset, label: 'Game Player'),
                _Badge(icon: Icons.lock, label: 'Locked'),
              ],
            ),
            const SizedBox(height: 32),
            SmoothButton(
              label: 'Sign out',
              variant: SmoothButtonVariant.outline,
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final locked = label == 'Locked';
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: locked ? AppColors.surfaceVariant : AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: locked ? AppColors.textMuted : AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
