import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/role_utils.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/profile_cover_header.dart';
import 'profile_portfolio_section.dart' show showNewPublicationSheet, userPublicationsProvider;
import 'publication_tile.dart';

class MomentsScreen extends ConsumerWidget {
  const MomentsScreen({super.key, this.userId});

  /// When null, shows the signed-in user's moments.
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final me = ref.watch(authProvider).user;
    final targetId = userId ?? me?.id;
    final isOwn = me != null && targetId == me.id;

    if (targetId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.moments)),
        body: Center(child: Text(s.signInRequired)),
      );
    }

    final pubsAsync = ref.watch(userPublicationsProvider(targetId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 168,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(s.moments, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    isOwn ? profileCoverForUser(me) : AppAssets.learningDesk,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOwn) ...[
                    Text(
                      me.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleDisplayName(me.role),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    s.momentsSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: pubsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('$e')),
              ),
              data: (pubs) {
                if (pubs.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_outlined, size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          s.noPublications,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            s.momentsEmptyHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                          ),
                        ),
                        if (isOwn) ...[
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => showNewPublicationSheet(
                              context: context,
                              ref: ref,
                              userId: targetId,
                              defaultKind: me.role == UserRole.client ? 'offer' : 'post',
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(s.newPublication),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return SliverList.separated(
                  itemCount: pubs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) => PublicationTile(publication: pubs[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isOwn
          ? FloatingActionButton.extended(
              onPressed: () => showNewPublicationSheet(
                context: context,
                ref: ref,
                userId: targetId,
                defaultKind: me.role == UserRole.client ? 'offer' : 'post',
              ),
              backgroundColor: AppColors.accentPurple,
              icon: const Icon(Icons.add),
              label: Text(s.newPublication),
            )
          : null,
    );
  }
}
