import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import 'provider_reviews_service.dart';

Future<void> showContactProviderSheet({
  required BuildContext context,
  required WidgetRef ref,
  required AppUser provider,
}) async {
  final s = S.of(context);
  final me = ref.read(authProvider).user;
  final subjectCtrl = TextEditingController(text: s.contactProviderSubject(provider.displayName));
  final bodyCtrl = TextEditingController();
  var sending = false;

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
                Text(s.contactProvider, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  provider.displayName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: subjectCtrl,
                  decoration: InputDecoration(
                    labelText: s.subject,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: s.message,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: sending || bodyCtrl.text.trim().isEmpty
                      ? null
                      : () async {
                          setState(() => sending = true);
                          await ref.read(databaseProvider).createContactMessage(
                                userId: me?.id,
                                name: me?.displayName ?? 'User',
                                email: me?.email ?? 'user@smooth.app',
                                subject: subjectCtrl.text.trim(),
                                body: bodyCtrl.text.trim(),
                              );
                          ref.invalidate(userMessagesProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.messageSent)),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(s.sendMessage, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  subjectCtrl.dispose();
  bodyCtrl.dispose();
}

Future<void> showLeaveReviewSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String providerId,
  required String providerName,
  String? contextLabel,
}) async {
  final s = S.of(context);
  final me = ref.read(authProvider).user;
  if (me == null) return;

  var rating = 5.0;
  final commentCtrl = TextEditingController();
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
                Text(s.leaveReview, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  providerName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                if (contextLabel != null && contextLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(contextLabel, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
                const SizedBox(height: 16),
                Text(s.yourRating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      onPressed: () => setState(() => rating = star.toDouble()),
                      icon: Icon(
                        rating >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.accentOrange,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: s.reviewComment,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving || commentCtrl.text.trim().isEmpty
                      ? null
                      : () async {
                          setState(() => saving = true);
                          await ref.read(providerReviewsServiceProvider).addReview(
                                providerId: providerId,
                                authorName: me.displayName,
                                rating: rating,
                                comment: commentCtrl.text.trim(),
                                context: contextLabel ?? s.learn,
                              );
                          ref.invalidate(providerReviewsListProvider(providerId));
                          ref.invalidate(providerStatsProvider(providerId));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.reviewSubmitted)),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(s.submitReview, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  commentCtrl.dispose();
}
