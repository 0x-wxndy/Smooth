import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/smooth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
    if (mounted && ref.read(authProvider).status == AuthStatus.authenticated) {
      context.go('/home');
    }
  }

  Future<void> _demo(String email) async {
    _email.text = email;
    _password.text = AppConfig.demoPassword;
    await ref.read(authProvider.notifier).login(
          email: email,
          password: AppConfig.demoPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final s = S.of(context);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(s.signIn)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.tryDemoAccounts, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DemoChip(
                  label: s.demoLearnerLabel,
                  color: AppColors.accentBlue,
                  onTap: () => _demo(AppConfig.demoLearnerEmail),
                ),
                _DemoChip(
                  label: s.demoTeacherLabel,
                  color: AppColors.accentPurple,
                  onTap: () => _demo(AppConfig.demoTeacherEmail),
                ),
                _DemoChip(
                  label: s.demoClientLabel,
                  color: AppColors.accentGreen,
                  onTap: () => _demo(AppConfig.demoClientEmail),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SmoothButton(
              label: s.signIn,
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/role'),
              child: Text(s.createAccount),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(Icons.bolt_rounded, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}
