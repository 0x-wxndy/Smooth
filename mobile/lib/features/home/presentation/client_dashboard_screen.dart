import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/cards.dart';

class ClientDashboardTab extends ConsumerWidget {
  const ClientDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Hub'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${user?.displayName ?? 'Client'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Find talent, book sessions & post jobs',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SmoothButton(
            label: 'Browse freelancers',
            icon: Icons.person_search,
            onPressed: () => context.go('/market'),
          ),
          const SizedBox(height: 12),
          SmoothButton(
            label: 'Post a job',
            variant: SmoothButtonVariant.outline,
            icon: Icons.post_add,
            onPressed: () => context.go('/jobs'),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Top services'),
          AsyncValueContent(
            value: servicesAsync,
            builder: (services) => Column(
              children: services.take(3).map((s) => ServiceCard(
                    service: s,
                    onTap: () => context.push('/services/${s.id}'),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
