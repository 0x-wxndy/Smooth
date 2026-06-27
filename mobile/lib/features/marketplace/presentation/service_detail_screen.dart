import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_button.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceProvider(serviceId));

    return AsyncValueContent(
      value: serviceAsync,
      builder: (service) {
        if (service == null) {
          return const Scaffold(body: Center(child: Text('Service not found')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Service')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                service.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${service.providerName} · ★ ${service.ratingAvg} (${service.reviewCount} reviews)',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(service.description, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _StatBox(label: 'Price', value: service.priceLabel),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Delivery', value: '${service.deliveryDays} days'),
                ],
              ),
              const SizedBox(height: 24),
              const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              const ListTile(
                title: Text('How many revisions?'),
                subtitle: Text('Up to 3 revisions included.'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SmoothButton(
                      label: 'Request quote',
                      variant: SmoothButtonVariant.outline,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: SmoothButton(label: 'Book now', onPressed: () {})),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
