import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import 'home_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'client_dashboard_screen.dart';

/// Routes `/home` to the correct dashboard based on the signed-in user's role.
class RoleHomeTab extends ConsumerWidget {
  const RoleHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role ?? UserRole.learner;

    return switch (role) {
      UserRole.teacher => const TeacherDashboardTab(),
      UserRole.client => const ClientDashboardTab(),
      UserRole.admin => const HomeTab(),
      UserRole.learner => const HomeTab(),
    };
  }
}
