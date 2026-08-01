import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/marketplace_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/smooth_components.dart';
import '../../profile/presentation/provider_profile_screen.dart';

/// Full categorized directory of teachers/freelancers — reached via "See all".
class AllProvidersScreen extends ConsumerStatefulWidget {
  const AllProvidersScreen({super.key});

  @override
  ConsumerState<AllProvidersScreen> createState() => _AllProvidersScreenState();
}

class _AllProvidersScreenState extends ConsumerState<AllProvidersScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final providersAsync = ref.watch(learnProvidersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.learnMentorsTitle)),
      body: AsyncValueContent(
        value: providersAsync,
        builder: (providers) {
          final categories = <String>{for (final p in providers) p.headline}.toList()..sort();
          final filtered = _category == null
              ? providers
              : providers.where((p) => p.headline == _category).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: [
                    SmoothChipFilter(
                      label: s.filterAll,
                      selected: _category == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    ...categories.map(
                      (c) => SmoothChipFilter(
                        label: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(s.noUsersInCategory, style: const TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _ProviderRow(provider: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.provider});

  final FeaturedProvider provider;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(
              provider.avatarUrl ?? featuredAvatarForIndex(provider.userId.hashCode),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(provider.headline, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StarRatingRowInline(rating: provider.ratingAvg),
                    const SizedBox(width: 6),
                    Text(
                      provider.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/providers/${provider.userId}'),
            child: Text(s.viewProfile),
          ),
        ],
      ),
    );
  }
}

/// Tiny inline star row without pulling in the full provider_feedback widget tree.
class StarRatingRowInline extends StatelessWidget {
  const StarRatingRowInline({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i;
        return Icon(
          filled ? Icons.star_rounded : half ? Icons.star_half_rounded : Icons.star_outline_rounded,
          size: 14,
          color: AppColors.accentOrange,
        );
      }),
    );
  }
}