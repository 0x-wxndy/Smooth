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
import '../../profile/presentation/provider_review_form.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceProvider(serviceId));
    final me = ref.watch(authProvider).user;
    final s = S.of(context);

    return AsyncValueContent(
      value: serviceAsync,
      builder: (service) {
        if (service == null) {
          return Scaffold(body: Center(child: Text(s.serviceNotFound)));
        }

        final canReview = service.providerId != null &&
            canLeaveProviderReview(me, providerId: service.providerId!);
        final isOwner = me?.id == service.providerId;

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
                    '★ ${service.ratingAvg} (${s.reviewsLabel(service.reviewCount)})',
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
              if (canReview) ...[
                const SizedBox(height: 24),
                ProviderReviewForm(
                  providerId: service.providerId!,
                  providerName: service.providerName ?? 'Provider',
                  contextLabel: service.title,
                ),
              ],
              const SizedBox(height: 24),
              Text(s.faqTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              ListTile(
                title: Text(s.faqRevisionsQ),
                subtitle: Text(s.faqRevisionsA),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 80),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (service.providerId != null && !isOwner) ...[
                    SizedBox(
                      width: double.infinity,
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
                    const SizedBox(height: 10),
                  ],
                  if (!isOwner)
                    Row(
                      children: [
                        Expanded(
                          child: SmoothButton(
                            label: s.requestQuote,
                            variant: SmoothButtonVariant.outline,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s.quoteSentDemo)),
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
