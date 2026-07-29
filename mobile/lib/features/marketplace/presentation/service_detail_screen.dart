import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/payments/payment_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_button.dart';
import '../../../shared/widgets/provider_name_link.dart';
import '../../profile/presentation/provider_actions.dart';
import '../../profile/presentation/provider_profile_screen.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceProvider(serviceId));
    final s = S.of(context);

    return AsyncValueContent(
      value: serviceAsync,
      builder: (service) {
        if (service == null) {
          return const Scaffold(body: Center(child: Text('Service not found')));
        }

        return Scaffold(
          appBar: AppBar(title: Text(s.services)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                service.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (service.providerName != null)
                    ProviderNameLink(
                      name: service.providerName!,
                      providerId: service.providerId,
                    ),
                  Text(
                    '★ ${service.ratingAvg} (${service.reviewCount} reviews)',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(service.description, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _StatBox(label: s.price, value: service.priceLabel),
                  const SizedBox(width: 12),
                  _StatBox(label: s.deliveryDays, value: '${service.deliveryDays}'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A317).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8A317).withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFE8A317)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.payWithEdahabia,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      'CIB · Card',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (service.providerId != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref.read(providerProfileProvider(service.providerId!).future).then((user) {
                                if (user != null && context.mounted) {
                                  showContactProviderSheet(context: context, ref: ref, provider: user);
                                }
                              });
                            },
                            icon: const Icon(Icons.mail_outline_rounded, size: 18),
                            label: Text(s.contactProvider),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => showLeaveReviewSheet(
                              context: context,
                              ref: ref,
                              providerId: service.providerId!,
                              providerName: service.providerName ?? 'Provider',
                              contextLabel: service.title,
                            ),
                            icon: const Icon(Icons.rate_review_outlined, size: 18),
                            label: Text(s.leaveReview),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: SmoothButton(
                          label: 'Request quote',
                          variant: SmoothButtonVariant.outline,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quote request sent (demo)')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SmoothButton(
                          label: s.bookNow,
                          onPressed: () {
                            context.push(
                              '/checkout',
                              extra: PaymentCheckoutArgs(
                                title: service.title,
                                subtitle: service.providerName,
                                amountCentimes: service.priceCents,
                                purpose: PaymentPurpose.service,
                                itemId: serviceId,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
