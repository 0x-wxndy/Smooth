import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/publication_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/async_content.dart';
import '../../../shared/widgets/cards.dart';

final userPublicationsProvider = FutureProvider.family<List<Publication>, String>((ref, userId) async {
  return ref.watch(databaseProvider).getPublications(authorId: userId);
});

class ProfilePortfolioSection extends ConsumerWidget {
  const ProfilePortfolioSection({super.key, required this.role, required this.userId});

  final UserRole role;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (role == UserRole.admin) return const SizedBox.shrink();

    final s = S.of(context);
    final pubsAsync = ref.watch(userPublicationsProvider(userId));
    final coursesAsync = ref.watch(role == UserRole.teacher ? myCoursesProvider : enrolledCoursesProvider);
    final servicesAsync = ref.watch(
      role == UserRole.teacher
          ? myServicesProvider
          : role == UserRole.client
              ? bookedServicesProvider
              : bookedServicesProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.portfolio, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            AsyncValueContent(
              value: coursesAsync,
              builder: (courses) => AsyncValueContent(
                value: servicesAsync,
                builder: (services) {
                  return Row(
                    children: [
                      Expanded(
                        child: _PortfolioStat(
                          icon: Icons.menu_book_rounded,
                          label: s.courses,
                          value: '${courses.length}',
                          color: AppColors.accentPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PortfolioStat(
                          icon: Icons.design_services_outlined,
                          label: s.services,
                          value: '${services.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AsyncValueContent(
                          value: pubsAsync,
                          builder: (pubs) => _PortfolioStat(
                            icon: Icons.article_outlined,
                            label: s.publications,
                            value: '${pubs.length}',
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (role == UserRole.teacher) ...[
              const SizedBox(height: 14),
              Text(s.previousWork, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              AsyncValueContent(
                value: servicesAsync,
                builder: (services) {
                  if (services.isEmpty) {
                    return Text(s.noServicesYet, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13));
                  }
                  return Column(
                    children: services
                        .take(2)
                        .map(
                          (svc) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ServiceCard(service: svc, onTap: () {}),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(s.publications, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                if (role == UserRole.teacher || role == UserRole.client)
                  TextButton.icon(
                    onPressed: () => showNewPublicationSheet(
                      context: context,
                      ref: ref,
                      userId: userId,
                      defaultKind: role == UserRole.client ? 'offer' : 'post',
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(s.newPublication, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AsyncValueContent(
              value: pubsAsync,
              builder: (pubs) {
                if (pubs.isEmpty) {
                  return Text(s.noPublications, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13));
                }
                return Column(
                  children: pubs.take(4).map((p) => _PublicationTile(publication: p)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


}
Future<void> showNewPublicationSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  String defaultKind = 'post',
}) async {
  final s = S.of(context);
  final bodyCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  var saving = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.newPublication, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(s.hashtagsHint, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(labelText: s.message, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tagsCtrl,
                  decoration: InputDecoration(
                    labelText: s.hashtags,
                    hintText: '#design #project',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving || bodyCtrl.text.trim().isEmpty
                      ? null
                      : () async {
                          setState(() => saving = true);
                          final tags = tagsCtrl.text
                              .split(RegExp(r'[\s,]+'))
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .toList();
                          await ref.read(databaseProvider).createPublication(
                                authorId: userId,
                                body: bodyCtrl.text.trim(),
                                hashtags: tags,
                                kind: defaultKind,
                              );
                          ref.invalidate(userPublicationsProvider(userId));
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: Text(s.publish, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  bodyCtrl.dispose();
  tagsCtrl.dispose();
}

class _PortfolioStat extends StatelessWidget {
  const _PortfolioStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PublicationTile extends StatelessWidget {
  const _PublicationTile({required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (publication.isOffer || publication.isAnnouncement)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: publication.isOffer ? AppColors.accentPurple.withValues(alpha: 0.15) : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                publication.isOffer ? 'Offer' : 'Announcement',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: publication.isOffer ? AppColors.accentPurple : AppColors.primary,
                ),
              ),
            ),
          Text(publication.body, style: const TextStyle(fontSize: 13, height: 1.35)),
          if (publication.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: publication.hashtags
                  .map(
                    (h) => Text(
                      h.startsWith('#') ? h : '#$h',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
