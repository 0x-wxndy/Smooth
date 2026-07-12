import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/smooth_components.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _demoLogin(WidgetRef ref, BuildContext context, String email) async {
    await ref.read(authProvider.notifier).login(
          email: email,
          password: AppConfig.demoPassword,
        );
    if (context.mounted && ref.read(authProvider).status == AuthStatus.authenticated) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: NetworkCover(
              url: AppAssets.heroOffice,
              height: 280,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              overlay: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navy.withValues(alpha: 0.35),
                  AppColors.navy.withValues(alpha: 0.9),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientPrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.waves, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const Spacer(),
                      Text(
                        s.tagline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.12),
                      const SizedBox(height: 8),
                      Text(
                        s.heroSubtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SmoothButton(
                  label: s.getStarted,
                  onPressed: () => context.push('/role'),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 10),
                SmoothButton(
                  label: 'Google',
                  variant: SmoothButtonVariant.outline,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () => context.push('/login'),
                ),
                const SizedBox(height: 22),
                Text(
                  s.tryDemoAccounts,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  s.demoTapLogin,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                _DemoRoleCard(
                  accent: AppColors.accentBlue,
                  icon: Icons.school_rounded,
                  title: s.learnerRole,
                  badge: s.demoLearnerLabel,
                  description: s.learnerDesc,
                  email: AppConfig.demoLearnerEmail,
                  cta: s.startLearning,
                  loading: auth.isLoading,
                  onLogin: () => _demoLogin(ref, context, AppConfig.demoLearnerEmail),
                  onRegister: () => context.push('/register?role=${UserRole.learner.name}'),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08),
                const SizedBox(height: 12),
                _DemoRoleCard(
                  accent: AppColors.accentPurple,
                  icon: Icons.headset_mic_rounded,
                  title: s.teacherRole,
                  badge: s.demoTeacherLabel,
                  description: s.teacherDesc,
                  email: AppConfig.demoTeacherEmail,
                  cta: s.startAsCreator,
                  loading: auth.isLoading,
                  onLogin: () => _demoLogin(ref, context, AppConfig.demoTeacherEmail),
                  onRegister: () => context.push('/register?role=${UserRole.teacher.name}'),
                ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.08),
                const SizedBox(height: 12),
                _DemoRoleCard(
                  accent: AppColors.accentGreen,
                  icon: Icons.work_outline_rounded,
                  title: s.clientRole,
                  badge: s.demoClientLabel,
                  description: s.clientDesc,
                  email: AppConfig.demoClientEmail,
                  cta: s.postProject,
                  loading: auth.isLoading,
                  onLogin: () => _demoLogin(ref, context, AppConfig.demoClientEmail),
                  onRegister: () => context.push('/register?role=${UserRole.client.name}'),
                ).animate().fadeIn(delay: 420.ms).slideY(begin: 0.08),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(auth.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.alreadyHaveAccount,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(s.signIn, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoRoleCard extends StatelessWidget {
  const _DemoRoleCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.badge,
    required this.description,
    required this.email,
    required this.cta,
    required this.loading,
    required this.onLogin,
    required this.onRegister,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String badge;
  final String description;
  final String email;
  final String cta;
  final bool loading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$email\n${AppConfig.demoPassword}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(cta, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          TextButton(
            onPressed: onRegister,
            child: Text(
              S.of(context).createAccount,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
