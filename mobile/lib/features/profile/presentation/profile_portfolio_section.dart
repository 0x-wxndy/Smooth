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
import '../../../shared/widgets/profile_cover_header.dart';
import '../../../shared/widgets/cards.dart';
import 'portfolio_gallery.dart';
import 'publication_tile.dart';
import 'publication_media_helper.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

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
          : bookedServicesProvider,
    );

    final sectionTitle = switch (role) {
      UserRole.teacher => s.portfolio,
      UserRole.client => s.clientShowcaseTitle,
      _ => s.learningJourney,
    };
    final sectionSubtitle = switch (role) {
      UserRole.teacher => s.previousWork,
      UserRole.client => s.clientShowcaseSub,
      _ => s.learningJourneySub,
    };
    final sectionIcon = switch (role) {
      UserRole.teacher => Icons.collections_outlined,
      UserRole.client => Icons.work_outline_rounded,
      _ => Icons.route_outlined,
    };
    final feedLabel = role == UserRole.learner ? s.moments : s.publications;

    return ProfileSectionCard(
      title: sectionTitle,
      subtitle: sectionSubtitle,
      icon: sectionIcon,
      iconColor: AppColors.accentPurple,
      action: switch (role) {
        UserRole.teacher || UserRole.client => TextButton.icon(
            onPressed: () => showNewPublicationSheet(
              context: context,
              ref: ref,
              userId: userId,
              defaultKind: role == UserRole.client ? 'offer' : 'post',
            ),
            icon: const Icon(Icons.add, size: 16),
            label: Text(s.newPublication, style: const TextStyle(fontSize: 12)),
          ),
        UserRole.learner => TextButton.icon(
            onPressed: () => context.push('/profile/moments'),
            icon: const Icon(Icons.auto_stories_outlined, size: 16),
            label: Text(s.moments, style: const TextStyle(fontSize: 12)),
          ),
        _ => null,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          label: role == UserRole.learner ? s.bookedServicesLabel : s.services,
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
              const SizedBox(height: 18),
              Text(s.previousWork, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 10),
              PortfolioGallery(items: mockPortfolioItems(userId)),
              const SizedBox(height: 16),
              AsyncValueContent(
                value: servicesAsync,
                builder: (services) {
                  if (services.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.services, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...services.take(2).map(
                            (svc) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ServiceCard(service: svc, onTap: () {}),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(feedLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            AsyncValueContent(
              value: pubsAsync,
              builder: (pubs) {
                if (pubs.isEmpty) {
                  return Text(
                    role == UserRole.learner ? s.momentsEmptyHint : s.noPublications,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  );
                }
                return Column(
                  children: pubs.take(4).map((p) => PublicationTile(publication: p)).toList(),
                );
              },
            ),
          ],
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
  var picking = false;
  List<String> imagePaths = [];

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
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: picking
                          ? null
                          : () async {
                              setState(() => picking = true);
                              final picked = await PublicationMediaHelper.pickImages();
                              setState(() {
                                imagePaths = [...imagePaths, ...picked];
                                picking = false;
                              });
                            },
                      icon: picking
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.image_outlined, size: 18),
                      label: Text('${imagePaths.length} photo(s)'),
                    ),
                  ],
                ),
                if (imagePaths.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagePaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Container(width: 64, height: 64, color: AppColors.surfaceVariant)
                                : Image.file(File(imagePaths[i]), width: 64, height: 64, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, size: 18, color: AppColors.error),
                              onPressed: () => setState(() => imagePaths = [...imagePaths]..removeAt(i)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],



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
                                imagePaths: imagePaths,
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
