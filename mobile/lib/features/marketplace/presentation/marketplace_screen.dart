import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../../shared/widgets/cards.dart';

class MarketTab extends ConsumerWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: AsyncValueContent(
        value: servicesAsync,
        builder: (services) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SmoothSearchField(readOnly: true, onTap: () => context.push('/search')),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Popular services'),
            ...services.map(
              (s) => ServiceCard(
                service: s,
                onTap: () => context.push('/services/${s.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
