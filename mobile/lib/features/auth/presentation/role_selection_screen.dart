import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  void _continue(UserRole role) {
    context.push('/register?role=${role.name}');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHero),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.welcome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.choosePath,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _RolePathCard(
                  accent: AppColors.accentBlue,
                  icon: Icons.school_rounded,
                  title: s.learnerRole,
                  description: s.learnerDesc,
                  cta: s.startLearning,
                  selected: _selected == UserRole.learner,
                  onSelect: () => setState(() => _selected = UserRole.learner),
                  onCta: () => _continue(UserRole.learner),
                ),
                const SizedBox(height: 14),
                _RolePathCard(
                  accent: AppColors.accentPurple,
                  icon: Icons.headset_mic_rounded,
                  title: s.teacherRole,
                  description: s.teacherDesc,
                  cta: s.startAsCreator,
                  selected: _selected == UserRole.teacher,
                  onSelect: () => setState(() => _selected = UserRole.teacher),
                  onCta: () => _continue(UserRole.teacher),
                ),
                const SizedBox(height: 14),
                _RolePathCard(
                  accent: AppColors.accentGreen,
                  icon: Icons.work_outline_rounded,
                  title: s.clientRole,
                  description: s.clientDesc,
                  cta: s.postProject,
                  selected: _selected == UserRole.client,
                  onSelect: () => setState(() => _selected = UserRole.client),
                  onCta: () => _continue(UserRole.client),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePathCard extends StatelessWidget {
  const _RolePathCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.description,
    required this.cta,
    required this.selected,
    required this.onSelect,
    required this.onCta,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String description;
  final String cta;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : accent.withValues(alpha: 0.35),
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: selected ? 0.15 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accent, size: 28),
                ),
                const Spacer(),
                if (selected) Icon(Icons.check_circle_rounded, color: accent),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(cta, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
