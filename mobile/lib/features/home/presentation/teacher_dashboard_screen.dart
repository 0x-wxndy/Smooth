import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/smooth_button.dart';

class TeacherDashboardTab extends ConsumerWidget {
  const TeacherDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.displayName ?? 'Creator'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Teacher / Freelancer account',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Your stats'),
          Row(
            children: [
              _StatCard(icon: Icons.people, label: 'Students', value: '0'),
              const SizedBox(width: 12),
              _StatCard(icon: Icons.menu_book, label: 'Courses', value: '0'),
              const SizedBox(width: 12),
              _StatCard(icon: Icons.work, label: 'Projects', value: '0'),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick actions'),
          _ActionCard(
            icon: Icons.add_circle_outline,
            title: 'Create a course',
            subtitle: 'Upload lessons, videos & quizzes',
            onTap: () => context.push('/teacher/courses'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.design_services,
            title: 'Add a service',
            subtitle: 'Offer freelance work on the marketplace',
            onTap: () => context.push('/teacher/services'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.calendar_month,
            title: 'Manage bookings',
            subtitle: 'Mentoring sessions & reservations',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => SmoothCard(
              child: Row(
                children: [
                  LevelBadge(level: stats.level),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${stats.coins} coins · ${stats.xp} XP',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Browse platform'),
          SmoothButton(
            label: 'Explore courses & market',
            variant: SmoothButtonVariant.outline,
            onPressed: () => context.go('/learn'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SmoothCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
