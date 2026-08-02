import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/publication_model.dart';

class PublicationTile extends StatelessWidget {
  const PublicationTile({super.key, required this.publication});

  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (publication.isOffer || publication.isAnnouncement)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: publication.isOffer
                    ? AppColors.accentPurple.withValues(alpha: 0.12)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                publication.isOffer ? s.publicationKindOffer : s.publicationKindAnnouncement,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: publication.isOffer ? AppColors.accentPurple : AppColors.primary,
                ),
              ),
            ),
          Text(publication.body, style: const TextStyle(fontSize: 14, height: 1.45)),
          if (publication.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: publication.imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Container(
                          width: 100,
                          height: 100,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
                        )
                      : Image.file(
                          File(publication.imagePaths[i]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(width: 100, height: 100, color: AppColors.surfaceVariant),
                        ),
                ),
              ),
            ),
          ],
          if (publication.hashtags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: publication.hashtags
                  .map(
                    (h) => Text(
                      h.startsWith('#') ? h : '#$h',
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
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
